local M = {}

---@param root string
local function fingerprint(root)
  local entries = {}
  for path, kind in
    vim.fs.dir(root, {
      depth = math.huge,
      skip = function(path)
        local name = vim.fs.basename(path)
        return name ~= '.git' and name ~= 'target' and name ~= '.direnv'
      end,
    })
  do
    if kind == 'file' then
      if vim.fs.basename(path) == 'pom.xml' then
        entries[#entries + 1] = path .. '\0' .. table.concat(vim.fn.readfile(vim.fs.joinpath(root, path)), '\n')
      elseif path:sub(-5) == '.java' then
        entries[#entries + 1] = path
      end
    end
  end
  table.sort(entries)
  return vim.fn.sha256(table.concat(entries, '\0'))
end

---@param root string
function M.new(root)
  local snapshot = fingerprint(root)
  local waiting
  local base_config
  local workspace = {}

  ---@param client? vim.lsp.Client
  ---@param bufnr integer
  ---@param callback fun(err?: {kind: string, message: string})
  function workspace:sync(client, bufnr, callback)
    if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
    if waiting then
      waiting[#waiting + 1] = callback
      return
    end
    local current = fingerprint(root)
    if current == snapshot then
      callback()
      return
    end
    if not client then
      callback({ kind = 'client', message = 'No jdtls client available to refresh the Java workspace' })
      return
    end
    local callbacks = { callback }
    waiting = callbacks
    local done = false
    local deadline = vim.uv.hrtime() + 120 * 1e9
    local timer
    local function finish(err)
      if done then return end
      done = true
      if timer and not timer:is_closing() then
        timer:stop()
        timer:close()
      end
      if not err then snapshot = current end
      waiting = nil
      for _, cb in ipairs(callbacks) do
        cb(err)
      end
    end

    base_config = base_config or vim.deepcopy(client.config)
    local config = vim.deepcopy(base_config)
    config.handlers = config.handlers or {}
    local original_status = config.handlers['language/status']
    config.handlers['language/status'] = function(err, status, ctx, ...)
      if original_status then original_status(err, status, ctx, ...) end
      if err or (status and (status.type == 'ERROR' or status.type == 'Error')) then
        finish({ kind = 'refresh', message = 'Java workspace import failed; check Java diagnostics' })
      elseif status and status.type == 'ServiceReady' then
        finish()
      end
    end
    local buffers = vim.tbl_keys(client.attached_buffers)
    local old_id = client.id
    local new_id
    local poll = vim.uv.new_timer()
    if not poll then
      finish({ kind = 'refresh', message = 'Could not create a timer for Java workspace refresh' })
      return
    end
    timer = poll
    client:stop()
    vim.notify('Java project structure changed; restarting JDTLS before launch', vim.log.levels.INFO, { title = 'Java' })
    poll:start(
      0,
      50,
      vim.schedule_wrap(function()
        if done then return end
        if vim.uv.hrtime() > deadline then
          finish({ kind = 'timeout', message = 'Timed out refreshing the Java workspace; launch cancelled' })
          return
        end
        if not new_id and not vim.lsp.get_client_by_id(old_id) then
          local primary = vim.api.nvim_buf_is_valid(bufnr) and bufnr or nil
          if not primary then
            finish({ kind = 'refresh', message = 'Java launch buffer was deleted during workspace refresh' })
            return
          end
          new_id = vim.lsp.start(config, { bufnr = primary, reuse_client = function() return false end })
          if not new_id then
            finish({ kind = 'refresh', message = 'Could not restart JDTLS to refresh the Java workspace' })
            return
          end
          for _, buf in ipairs(buffers) do
            if vim.api.nvim_buf_is_valid(buf) then vim.lsp.buf_attach_client(buf, new_id) end
          end
        elseif new_id and not vim.lsp.get_client_by_id(new_id) then
          finish({ kind = 'refresh', message = 'JDTLS exited while refreshing the Java workspace' })
        end
      end)
    )
  end

  return workspace
end

return M
