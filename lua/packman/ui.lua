local registry = require('packman.registry')
local cache = require('packman.cache')

local M = {}

local NS = vim.api.nvim_create_namespace('packman_ui')

--- 打开浮窗的通用函数
---@param title string
---@param lines string[]
---@param highlights table[] 每项: { line, col1, col2, hl_group }
local function open_float(title, lines, highlights)
  local width = math.floor(vim.o.columns * 0.55)
  local height = math.min(math.floor(vim.o.lines * 0.6), #lines + 4)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].bufhidden = 'wipe'
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].readonly = true

  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  local win = vim.api.nvim_open_win(bufnr, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = ' ' .. title .. ' ',
    title_pos = 'center',
  })

  -- 高亮
  vim.schedule(function()
    for _, h in ipairs(highlights or {}) do
      pcall(function() vim.hl.range(bufnr, NS, h.hl_group, { h.line, h.col1 }, { h.line, h.col2 }, { inclusive = false, priority = 100 }) end)
    end
  end)

  -- 关闭键
  local function close()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '', { nowait = true, noremap = true, silent = true, callback = close })
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Esc>', '', { nowait = true, noremap = true, silent = true, callback = close })
end

--- 获取已安装插件信息
---@return table[] 每项: { name, spec }
local function get_installed()
  local res = vim.pack.get(nil, { info = true }) or {}
  local plugins = {}
  for _, p in ipairs(res) do
    if p.spec and p.spec.name then table.insert(plugins, { name = p.spec.name, spec = p.spec }) end
  end
  table.sort(plugins, function(a, b) return a.name < b.name end)
  return plugins
end

--- 从 src 中提取作者名
---@param src string
---@return string
local function parse_author(src)
  if not src then return '-' end
  local owner = src:match('github%.com/([^/]+)/')
  if owner then return owner end
  return src:match('https?://([^/]+)') or '-'
end

--- PackInstalled 命令
function M.pack_installed()
  local installed = get_installed()
  local lines = {}
  local highlights = {}

  table.insert(lines, string.format('  Installed plugins: %d', #installed))
  table.insert(highlights, { line = 0, col1 = 0, col2 = -1, hl_group = 'Title' })
  table.insert(lines, '')

  for _, p in ipairs(installed) do
    local author = parse_author(p.spec.src)
    local status = registry.is_loaded(p.name) and '[LOADED]' or '[LAZY]  '
    local version = p.spec.version and ('  ' .. tostring(p.spec.version)) or ''
    local line_text = string.format('  %s %-30s %s%s', status, p.name, author, version)
    table.insert(lines, line_text)
    local idx = #lines - 1
    table.insert(highlights, {
      line = idx,
      col1 = 2,
      col2 = 2 + #status,
      hl_group = registry.is_loaded(p.name) and 'DiagnosticOk' or 'DiagnosticWarn',
    })
    table.insert(lines, '')
  end

  open_float('Pack Installed', lines, highlights)
end

--- PackStatus 命令
function M.pack_status()
  local declared = registry.get_all()
  local lines = {}
  local highlights = {}

  local loaded_count = 0
  local lazy_count = 0

  for _, name in ipairs(declared) do
    if registry.is_loaded(name) then
      loaded_count = loaded_count + 1
    else
      lazy_count = lazy_count + 1
    end
  end

  table.insert(lines, string.format('  Loaded: %d  |  Lazy: %d  |  Total: %d', loaded_count, lazy_count, #declared))
  table.insert(highlights, { line = 0, col1 = 0, col2 = -1, hl_group = 'Title' })
  table.insert(lines, '')

  for _, name in ipairs(declared) do
    local is_loaded = registry.is_loaded(name)
    local status = is_loaded and '[LOADED]' or '[LAZY]  '
    local ms = cache.load_times[name]
    local time_str = ms and string.format('%dms', ms) or ''
    local line_text = string.format('  %s %-30s %s', status, name, time_str)
    table.insert(lines, line_text)
    local idx = #lines - 1
    table.insert(highlights, {
      line = idx,
      col1 = 2,
      col2 = 2 + #status,
      hl_group = is_loaded and 'DiagnosticOk' or 'DiagnosticWarn',
    })
    table.insert(lines, '')
  end

  open_float('Pack Status', lines, highlights)
end

--- PackProfile 命令
function M.pack_profile()
  local sorted = cache.get_sorted()
  local total = cache.total()
  local max_ms = #sorted > 0 and sorted[1].ms or 1

  local lines = {}
  local highlights = {}

  table.insert(lines, string.format('  Total: %dms', total))
  table.insert(highlights, { line = 0, col1 = 0, col2 = -1, hl_group = 'Title' })
  table.insert(lines, '')

  for i, entry in ipairs(sorted) do
    local bar_len = math.max(1, math.floor((entry.ms / max_ms) * 20))
    local bar = string.rep('\xe2\x96\x88', bar_len)
    local line_text = string.format('  %2d. %-30s %4dms  %s', i, entry.name, entry.ms, bar)
    table.insert(lines, line_text)
    table.insert(lines, '')
  end

  if #sorted == 0 then table.insert(lines, '  No load time data yet') end

  open_float('Pack Profile', lines, highlights)
end

--- 注册所有 Pack 命令
function M.register_commands()
  local reg = vim.api.nvim_create_user_command

  reg('PackInstalled', function() M.pack_installed() end, { nargs = 0, desc = 'Show installed plugins' })

  reg('PackStatus', function() M.pack_status() end, { nargs = 0, desc = 'Show plugin status' })

  reg('PackProfile', function() M.pack_profile() end, { nargs = 0, desc = 'Show plugin load times' })

  reg('PackUpdate', function() vim.pack.update() end, { nargs = 0, desc = 'Update all plugins' })

  reg('PackSync', function()
    -- 1. 收集已声明插件
    local declared_srcs = {}
    for name, _ in pairs(registry.declared) do
      declared_srcs[name] = true
    end

    -- 2. 已安装插件
    local installed = {}
    for _, p in ipairs(vim.pack.get(nil, { info = true }) or {}) do
      if p.spec and p.spec.name then installed[p.spec.name] = p end
    end

    -- 3. 找出未声明插件(需要清理)
    local unused = {}
    for name, _ in pairs(installed) do
      if not declared_srcs[name] then table.insert(unused, name) end
    end

    -- 4. 找出未安装插件(需要安装)
    local missing = {}
    for name, _ in pairs(declared_srcs) do
      if not installed[name] then table.insert(missing, name) end
    end

    -- 5. 清理未声明插件(需确认)
    if #unused > 0 then
      table.sort(unused)
      local msg = '  Remove unused plugins?\n\n  ' .. table.concat(unused, '\n  ')
      local confirm = vim.fn.input(msg .. '\n\n  Type [Y]es to confirm: ')
      confirm = confirm:lower()
      if confirm == 'y' or confirm == 'yes' then
        vim.pack.del(unused)
        vim.notify('Removed ' .. #unused .. ' unused plugins')
      else
        vim.notify('PackSync: unused plugins kept', vim.log.levels.INFO)
      end
    end

    -- 6. 更新已有插件
    vim.pack.update()

    -- 7. 输出摘要
    if #missing == 0 and #unused == 0 then
      vim.notify('All plugins are in sync', vim.log.levels.INFO)
    else
      local msgs = {}
      if #missing > 0 then
        table.sort(missing)
        table.insert(msgs, string.format('Missing: %s', table.concat(missing, ', ')))
      end
      vim.notify(table.concat(msgs, '\n'), vim.log.levels.INFO)
    end
  end, { nargs = 0, desc = 'Sync plugin state (install + clean + update)' })

  reg('PackRemove', function(opts)
    local name = vim.trim(opts.args or '')
    if name == '' then
      vim.notify('PackRemove requires a plugin name', vim.log.levels.ERROR)
      return
    end
    local ok, err = pcall(function() vim.pack.del({ name }) end)
    if not ok then
      vim.notify('Failed to remove: ' .. tostring(err), vim.log.levels.ERROR)
      return
    end
    vim.notify('Removed: ' .. name)
  end, {
    nargs = 1,
    complete = function(arg_lead)
      local items = {}
      for _, p in ipairs(get_installed()) do
        if p.name:find(arg_lead, 1, true) then table.insert(items, p.name) end
      end
      return items
    end,
    desc = 'Remove a plugin',
  })

  reg('PackClean', function()
    local declared_srcs = {}
    for name, _ in pairs(registry.declared) do
      declared_srcs[name] = true
    end

    local unused = {}
    for _, p in ipairs(vim.pack.get(nil, { info = true }) or {}) do
      if p.spec and p.spec.name and not declared_srcs[p.spec.name] then table.insert(unused, p.spec.name) end
    end

    if #unused == 0 then
      vim.notify('No unused plugins')
      return
    end

    table.sort(unused)
    local msg = '  Remove unused plugins?\n\n  ' .. table.concat(unused, '\n  ')
    local confirm = vim.fn.input(msg .. '\n\n  Type [Y]es to confirm: ')
    confirm = confirm:lower()
    if confirm ~= 'y' and confirm ~= 'yes' then
      vim.notify('PackClean cancelled')
      return
    end

    vim.pack.del(unused)
    vim.notify('Cleaned ' .. #unused .. ' unused plugins')
  end, { desc = 'Remove undeclared plugins' })
end

return M
