local M = {}

M.declared = {}

local ICON = '󱐥 '
local NS = vim.api.nvim_create_namespace('pack_installed')

-- 对 vim.pack.add 进行包装, 记录声明的插件
function M.pack_state()
  local orig_add = vim.pack.add

  local function infer_name_from_src(src)
    if type(src) ~= 'string' then return nil end
    -- 去掉 .git
    src = src:gsub('%.git$', '')
    -- 取最后一段
    return src:match('/([^/]+)$')
  end

  --- @param specs (string|vim.pack.Spec)[] List of plugin specifications. String item
  --- is treated as `src`.
  --- @param opts? vim.pack.keyset.add
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.pack.add = function(specs, opts)
    -- 记录声明的插件
    local function record(item)
      if type(item) == 'string' then
        -- string spec 本身就是 src
        local name = infer_name_from_src(item)
        if name then M.declared[name] = true end
      elseif type(item) == 'table' then
        -- 显式 name 优先
        if type(item.name) == 'string' then
          M.declared[item.name] = true
          return
        end
        -- src 兜底
        if type(item.src) == 'string' then
          local name = infer_name_from_src(item.src)
          if name then M.declared[name] = true end
          return
        end
      end
    end

    if type(specs) == 'table' then
      for _, item in ipairs(specs) do
        record(item)
      end
    else
      record(specs)
    end

    return orig_add(specs, opts)
  end
end

-- 返回已安装插件名称的列表(来自 vim.pack.get())
function M.installed_plugins()
  local res = vim.pack.get(nil, { info = true })
  local names = {}
  for _, plug in ipairs(res or {}) do
    local name = nil
    if plug.spec and plug.spec.name then
      name = plug.spec.name
    else
      -- fallback to basename of path
      if plug.path then name = vim.fn.fnamemodify(plug.path, ':t') end
    end
    if name then table.insert(names, name) end
  end
  table.sort(names)
  return names
end

-- 返回已安装插件名称的列表
function M.installed_complete(args)
  local items = M.installed_plugins()
  local res = {}
  for _, v in ipairs(items) do
    if vim.startswith(v, args) then table.insert(res, v) end
  end
  return res
end

function M.find_lock_file()
  local p = vim.fn.stdpath('config') .. '/nvim-pack-lock.json'
  if vim.fn.filereadable(p) == 1 then return p end
  return nil
end

function M.short_rev(rev)
  if not rev then return '-' end
  if #rev <= 8 then return rev end
  return rev:sub(1, 7)
end

function M.parse_author_from_src(src)
  if not src or type(src) ~= 'string' then return nil end
  local owner = src:match('github%.com/([^/]+)/')
  if owner then return owner end
  local domain = src:match('https?://([^/]+)')
  if domain then return domain end
  return nil
end

-- 构建显示行以及高亮信息
function M.build_lines_and_highlights(installed, lock_plugins)
  local lines = {}
  local highlights = {}
  local PAD = 2

  -- header
  local header_line = string.rep(' ', PAD) .. string.format('Installed plugins: %d', #installed)
  table.insert(lines, header_line)
  local header_idx = #lines - 1
  table.insert(highlights, { line = header_idx, start = 0, finish = -1, hl = 'PackTitle' })
  table.insert(lines, '')

  for _, name in ipairs(installed) do
    local info = lock_plugins[name] or lock_plugins[name:gsub('%%.', '-')]
    local rev = info and info.rev and M.short_rev(info.rev) or '-'
    local version = info and info.version or '-'
    local src = info and info.src or '-'
    local author = M.parse_author_from_src(src) or '-'

    -- === 插件信息行 ===
    local name_display = string.format('%s[%s]', name, author)
    local line_text = string.rep(' ', PAD) .. ICON .. name_display .. ' ' .. version .. ' rev:' .. rev
    table.insert(lines, line_text)
    local info_line = #lines - 1
    table.insert(highlights, { line = info_line, start = 0, finish = -1, hl = 'PackItem' })

    -- === URL 行 ===
    local url_line = string.rep(' ', PAD + 1) .. tostring(src)
    table.insert(lines, url_line)
    local url_idx = #lines - 1
    table.insert(highlights, { line = url_idx, start = 0, finish = -1, hl = 'PackURL' })

    -- spacer
    table.insert(lines, '')
  end

  return lines, highlights
end

-- 打开浮动窗口并应用高亮
function M.open_floating_window(lines, highlights)
  local width = math.floor(vim.o.columns * 0.55)
  local height = math.min(math.floor(vim.o.lines * 0.6), #lines + 4)
  local bufnr = vim.api.nvim_create_buf(false, true)

  vim.bo[bufnr].bufhidden = 'wipe'
  vim.bo[bufnr].filetype = 'packlist'

  -- 设置内容
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].readonly = true

  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win_opts = { relative = 'editor', row = row, col = col, width = width, height = height, style = 'minimal', border = 'rounded' }
  local win = vim.api.nvim_open_win(bufnr, true, win_opts)

  -- 添加高亮
  vim.schedule(function()
    local ns_id = NS or vim.api.nvim_create_namespace('pack_installed')
    for _, h in ipairs(highlights) do
      pcall(function()
        local s = tonumber(h.start) or 0
        local e = tonumber(h.finish)

        local line_count = vim.api.nvim_buf_line_count(bufnr)
        if h.line < 0 or h.line >= line_count then error(('highlight line out of range: %d (line_count=%d)'):format(h.line, line_count)) end

        local line_text = vim.api.nvim_buf_get_lines(bufnr, h.line, h.line + 1, false)[1] or ''
        local max_col = #line_text

        if not e or e < 0 then e = max_col end

        if s < 0 then s = 0 end
        if s > max_col then s = max_col end
        if e < 0 then e = 0 end
        if e > max_col then e = max_col end

        if e <= s then
          if s < max_col then
            e = s + 1
          else
            s = math.max(0, s - 1)
          end
        end

        if vim.hl and type(vim.hl.range) == 'function' then
          vim.hl.range(bufnr, ns_id, h.hl, { h.line, s }, { h.line, e }, { inclusive = false, priority = 100 })
        else
          vim.api.nvim_buf_set_extmark(bufnr, ns_id, h.line, s, { end_row = h.line, end_col = e, hl_group = h.hl })
        end
      end)
    end
  end)

  -- 关闭函数
  local function close_fn()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end

  vim.api.nvim_set_hl(0, 'PackTitle', { link = 'Title' })
  vim.api.nvim_set_hl(0, 'PackItem', { link = 'Identifier' })
  vim.api.nvim_set_hl(0, 'PackURL', { link = 'Comment' })

  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', '', { nowait = true, noremap = true, silent = true, callback = close_fn })
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Esc>', '', { nowait = true, noremap = true, silent = true, callback = close_fn })
end

return M
