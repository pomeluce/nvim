---@diagnostic disable: param-type-mismatch
local registry = require('packman.registry')
local cache = require('packman.cache')

local M = {}

local NS = vim.api.nvim_create_namespace('packman_ui')

local TABS = { 'Plugins', 'Profile', 'Clean' }

--- Nerd Font 图标（带回退）
local ICONS = {
  loaded = '\u{f058}', -- nf-fa-check_circle
  lazy = '\u{f017}', -- nf-fa-clock_o
  missing = '\u{f057}', -- nf-fa-times_circle
  success = '\u{f00c}', -- nf-fa-check
  fail = '\u{f00d}', -- nf-fa-times
  bar = '\u{2588}', -- █
}

--- Panel 状态
local state = {
  win = nil,
  buf = nil,
  tab = 'Plugins',
  confirm_action = nil,
}

--- 判断面板是否已打开
---@return boolean
local function is_open() return state.win ~= nil and vim.api.nvim_win_is_valid(state.win) end

--- 解析作者名
---@param src string
---@return string
local function parse_author(src)
  if not src then return '-' end
  local owner = src:match('github%.com/([^/]+)/')
  if owner then return owner end
  return src:match('https?://([^/]+)') or '-'
end

--- 构建 Tab 栏行
---@return string
---@return table[] highlights 每项: { col1, col2, hl_group }
local function render_tab_bar()
  local parts = {}
  local hls = {}
  local col = 0

  for _, name in ipairs(TABS) do
    local is_active = name == state.tab
    local icon = is_active and '󰄲' or ''
    local icon_hl = is_active and 'DiagnosticOk' or 'NonText'
    local label = icon .. ' ' .. name .. ' '
    table.insert(parts, label)
    -- 图标高亮
    table.insert(hls, { col1 = col, col2 = col + #icon, hl_group = icon_hl })
    -- Tab 名高亮
    table.insert(hls, { col1 = col + #icon + 1, col2 = col + #label - 1, hl_group = is_active and 'Title' or 'Comment' })
    col = col + #label
  end

  return table.concat(parts), hls
end

-- Tab 渲染函数占位（后续 Task 实现）
local function render_plugins()
  local lines = {}
  local highlights = {}

  local all_specs = registry.get_all_specs()
  local installed = {}
  local pack_info = vim.pack.get(nil, { info = true }) or {}
  for _, p in ipairs(pack_info) do
    if p.spec and p.spec.name then installed[p.spec.name] = p.spec end
  end

  -- 统计
  local loaded_count = 0
  local lazy_count = 0
  local missing_count = 0
  for _, spec in ipairs(all_specs) do
    if registry.is_loaded(spec.name) then
      loaded_count = loaded_count + 1
    elseif installed[spec.name] then
      lazy_count = lazy_count + 1
    else
      missing_count = missing_count + 1
    end
  end

  table.insert(lines, string.format('  %d plugins  %d loaded  %d lazy  %d missing', #all_specs, loaded_count, lazy_count, missing_count))
  table.insert(highlights, { line = #lines - 1, col1 = 0, col2 = -1, hl_group = 'Title' })
  table.insert(lines, '')

  for _, spec in ipairs(all_specs) do
    local is_loaded = registry.is_loaded(spec.name)
    local is_installed = installed[spec.name] ~= nil
    local icon, hl_group

    if not is_installed then
      icon = ICONS.missing
      hl_group = 'DiagnosticError'
    elseif is_loaded then
      icon = ICONS.loaded
      hl_group = 'DiagnosticOk'
    else
      icon = ICONS.lazy
      hl_group = 'DiagnosticWarn'
    end

    local author = parse_author(spec.src)
    local version = is_installed and installed[spec.name].version and tostring(installed[spec.name].version) or ''
    if not is_installed then version = 'MISSING' end

    local line_text = string.format('  %s %-30s %-14s %s', icon, spec.name, author, version)
    table.insert(lines, line_text)
    table.insert(highlights, { line = #lines - 1, col1 = 2, col2 = 3, hl_group = hl_group })
    if not is_installed then
      local miss_start = string.len(string.format('  %s %-30s %-14s ', icon, spec.name, author))
      table.insert(highlights, {
        line = #lines - 1,
        col1 = miss_start,
        col2 = miss_start + 7,
        hl_group = 'DiagnosticError',
      })
    end
  end

  return lines, highlights
end

local function render_profile()
  local lines = {}
  local highlights = {}

  local sorted = cache.get_sorted()
  local total = cache.total()
  local max_ms = #sorted > 0 and sorted[1].ms or 1

  table.insert(lines, string.format('  Total load time: %.1fms', total))
  table.insert(highlights, { line = #lines - 1, col1 = 0, col2 = -1, hl_group = 'Title' })
  table.insert(lines, '')

  for i, entry in ipairs(sorted) do
    local bar_len = math.max(1, math.floor((entry.ms / max_ms) * 20))
    local bar = string.rep(ICONS.bar, bar_len)
    local line_text = string.format('  %2d. %-30s %6.1fms  %s', i, entry.name, entry.ms, bar)
    table.insert(lines, line_text)
  end

  if #sorted == 0 then table.insert(lines, '  No load time data yet') end

  return lines, highlights
end

local function render_clean()
  local lines = {}
  local highlights = {}

  local declared = {}
  for name, _ in pairs(registry.declared) do
    declared[name] = true
  end

  local unused = {}
  local pack_info = vim.pack.get(nil, { info = true }) or {}
  for _, p in ipairs(pack_info) do
    if p.spec and p.spec.name and not declared[p.spec.name] then table.insert(unused, { name = p.spec.name, spec = p.spec }) end
  end
  table.sort(unused, function(a, b) return a.name < b.name end)

  table.insert(lines, string.format('  %d undeclared plugins found', #unused))
  table.insert(highlights, { line = #lines - 1, col1 = 0, col2 = -1, hl_group = 'Title' })
  table.insert(lines, '')

  for _, p in ipairs(unused) do
    local author = parse_author(p.spec.src)
    local version = p.spec.version and tostring(p.spec.version) or ''
    local line_text = string.format('  %s %-30s %-12s %s', ICONS.lazy, p.name, author, version)
    table.insert(lines, line_text)
    table.insert(highlights, { line = #lines - 1, col1 = 2, col2 = 3, hl_group = 'DiagnosticWarn' })
  end

  if #unused == 0 then table.insert(lines, '  No undeclared plugins') end

  return lines, highlights
end

--- 全量渲染面板内容
local function render()
  if not is_open() then return end
  local buf = state.buf

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_clear_namespace(buf, NS, 0, -1)

  local lines = {}
  local highlights = {}

  -- Tab 栏
  local tab_line, tab_hls = render_tab_bar()
  table.insert(lines, tab_line)
  for _, h in ipairs(tab_hls) do
    table.insert(highlights, { line = 0, col1 = h.col1, col2 = h.col2, hl_group = h.hl_group })
  end

  -- 分隔线
  table.insert(lines, string.rep('─', 60))
  table.insert(highlights, { line = 1, col1 = 0, col2 = -1, hl_group = 'NonText' })

  -- Tab 内容
  local content_lines, content_hls
  if state.tab == 'Plugins' then
    content_lines, content_hls = render_plugins()
  elseif state.tab == 'Profile' then
    content_lines, content_hls = render_profile()
  elseif state.tab == 'Clean' then
    content_lines, content_hls = render_clean()
  else
    content_lines = { '' }
    content_hls = {}
  end

  -- 偏移高亮行号（Tab 栏占 2 行：tab_line + separator）
  for _, h in ipairs(content_hls) do
    h.line = h.line + 2
  end

  vim.list_extend(lines, content_lines)
  vim.list_extend(highlights, content_hls)

  -- 底部帮助行
  table.insert(lines, '')
  local help_line
  if state.confirm_action then
    if state.confirm_action.action == 'remove' then
      help_line = string.format('  Press X again within 3s to remove %s', state.confirm_action.target)
    elseif state.confirm_action.action == 'clean' then
      help_line = '  Press c again within 3s to confirm clean'
    end
  elseif state.tab == 'Plugins' then
    help_line = '  [X] Remove  [1-3] Tab  [?] Help  [q] Close'
  elseif state.tab == 'Clean' then
    help_line = '  [c] Clean all  [X] Remove  [1-3] Tab  [?] Help  [q] Close'
  elseif state.tab == 'Profile' then
    help_line = '  [R] Refresh  [1-3] Tab  [?] Help  [q] Close'
  else
    help_line = '  [1-3] Tab  [?] Help  [q] Close'
  end
  table.insert(lines, help_line)
  table.insert(highlights, { line = #lines - 1, col1 = 0, col2 = -1, hl_group = 'Comment' })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- 应用高亮
  for _, h in ipairs(highlights) do
    pcall(vim.hl.range, buf, NS, h.hl_group, { h.line, h.col1 }, { h.line, h.col2 }, { inclusive = false, priority = 100 })
  end

  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
end

--- 切换 Tab
---@param tab_name string
local function switch_tab(tab_name)
  if not vim.tbl_contains(TABS, tab_name) then return end
  state.tab = tab_name
  render()
end

--- 获取光标所在行的插件名
---@return string?
local function get_cursor_plugin_name()
  if not is_open() then return nil end
  local line = vim.api.nvim_win_get_cursor(state.win)[1]
  -- 跳过 Tab 栏(2 行) + 统计行 + 空行 = 从第 4 行开始是插件列表
  if line < 4 then return nil end
  local text = vim.api.nvim_get_current_line()
  -- 匹配插件名: 行格式为 "  <icon> name ..."（兼容 Nerd Font 多字节图标）
  local name = text:match('^  %S%s+(%S+)')
  return name
end

--- 设置 buffer keymaps
local function set_keymaps()
  local buf = state.buf

  -- 关闭
  local function close_panel()
    if is_open() then vim.api.nvim_win_close(state.win, true) end
    state.win = nil
    state.buf = nil
    -- 清理确认计时器
    if state.confirm_action and state.confirm_action.timer then
      state.confirm_action.timer:stop()
      state.confirm_action.timer:close()
    end
    state.confirm_action = nil
  end
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', { nowait = true, noremap = true, silent = true, callback = close_panel })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '', { nowait = true, noremap = true, silent = true, callback = close_panel })

  -- Tab 切换 (数字键)
  for i, name in ipairs(TABS) do
    vim.api.nvim_buf_set_keymap(buf, 'n', tostring(i), '', {
      nowait = true,
      noremap = true,
      silent = true,
      callback = function() switch_tab(name) end,
    })
  end

  -- Tab 切换 (Tab / Shift+Tab 循环)
  local function cycle_tab(direction)
    local idx = 0
    for i, name in ipairs(TABS) do
      if name == state.tab then idx = i break end
    end
    local next_idx = ((idx - 1 + direction) % #TABS) + 1
    switch_tab(TABS[next_idx])
  end
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Tab>', '', {
    noremap = true, silent = true,
    callback = function() cycle_tab(1) end,
  })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<S-Tab>', '', {
    noremap = true, silent = true,
    callback = function() cycle_tab(-1) end,
  })

  -- 帮助
  vim.api.nvim_buf_set_keymap(buf, 'n', '?', '', {
    nowait = true,
    noremap = true,
    silent = true,
    callback = function() vim.notify('Pack Manager: [1-3] Switch tab  [q] Close  [?] Help', vim.log.levels.INFO) end,
  })

  -- Clean all (with double-press confirmation)
  vim.api.nvim_buf_set_keymap(buf, 'n', 'c', '', {
    nowait = true,
    noremap = true,
    silent = true,
    callback = function()
      if state.tab ~= 'Clean' then return end

      if not state.confirm_action then
        state.confirm_action = {
          action = 'clean',
          timer = vim.uv.new_timer(),
        }
        state.confirm_action.timer:start(3000, 0, function()
          state.confirm_action = nil
          if is_open() then render() end
        end)
        render()
      elseif state.confirm_action.action == 'clean' then
        if state.confirm_action.timer then
          state.confirm_action.timer:stop()
          state.confirm_action.timer:close()
        end
        state.confirm_action = nil
        M.do_clean()
      end
    end,
  })

  -- Remove current plugin
  vim.api.nvim_buf_set_keymap(buf, 'n', 'X', '', {
    nowait = true,
    noremap = true,
    silent = true,
    callback = function()
      if state.tab == 'Plugins' or state.tab == 'Clean' then M.do_remove_current() end
    end,
  })

  -- Refresh (Profile Tab)
  vim.api.nvim_buf_set_keymap(buf, 'n', 'R', '', {
    nowait = true,
    noremap = true,
    silent = true,
    callback = function()
      if state.tab == 'Profile' then render() end
    end,
  })
end

--- 移除单个插件（带二次确认）
function M.do_remove_current()
  local name = get_cursor_plugin_name()
  if not name then return end

  if not state.confirm_action then
    state.confirm_action = {
      action = 'remove',
      target = name,
      timer = vim.uv.new_timer(),
    }
    state.confirm_action.timer:start(3000, 0, function()
      state.confirm_action = nil
      if is_open() then render() end
    end)
    render()
    return
  end

  -- 二次确认
  if state.confirm_action.action == 'remove' and state.confirm_action.target == name then
    if state.confirm_action.timer then
      state.confirm_action.timer:stop()
      state.confirm_action.timer:close()
    end
    state.confirm_action = nil

    local ok, err = pcall(function() vim.pack.del({ name }) end)
    if ok then
      vim.notify('Removed: ' .. name)
    else
      vim.notify('Failed to remove: ' .. tostring(err), vim.log.levels.ERROR)
    end
    render()
  end
end

--- 清理未声明插件
function M.do_clean()
  local declared = {}
  for name, _ in pairs(registry.declared) do
    declared[name] = true
  end

  local unused = {}
  for _, p in ipairs(vim.pack.get(nil, { info = true }) or {}) do
    if p.spec and p.spec.name and not declared[p.spec.name] then table.insert(unused, p.spec.name) end
  end
  table.sort(unused)

  if #unused == 0 then
    vim.notify('No undeclared plugins to clean', vim.log.levels.INFO)
    return
  end

  vim.pack.del(unused)
  vim.notify('Cleaned ' .. #unused .. ' undeclared plugins')
  render()
end

--- 打开面板
---@param tab? string 初始 Tab 名，默认 'Plugins'
function M.open(tab)
  -- 已打开：聚焦 + 切换 Tab
  if is_open() then
    vim.api.nvim_set_current_win(state.win)
    if tab then switch_tab(tab) end
    return
  end

  state.tab = tab or 'Plugins'

  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.7)
  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].bufhidden = 'wipe'
  vim.bo[state.buf].buftype = 'nofile'

  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
  })

  set_keymaps()
  render()
end

--- 注册 :Pack 命令
function M.register_commands()
  vim.api.nvim_create_user_command('Pack', function(opts)
    local tab = vim.trim(opts.args or '')
    ---@diagnostic disable-next-line: cast-local-type
    if tab == '' then tab = nil end
    if tab == 'update' then
      vim.pack.update()
      return
    end
    M.open(tab)
  end, {
    nargs = '?',
    complete = function() return { 'plugins', 'profile', 'clean', 'update' } end,
    desc = 'Open pack manager panel',
  })
end

return M
