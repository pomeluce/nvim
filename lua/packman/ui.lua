---@diagnostic disable: param-type-mismatch
local registry = require('packman.registry')
local cache = require('packman.cache')

local M = {}

local NS = vim.api.nvim_create_namespace('packman_ui')

local TABS = { 'Plugins', 'Profile', 'Update', 'Clean' }
local TAB_ICONS = { active = '●', inactive = '○' }

--- Panel 状态
local state = {
  win = nil,
  buf = nil,
  tab = 'Plugins',
  is_busy = false,
  cancelled = false,
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
    local icon = is_active and TAB_ICONS.active or TAB_ICONS.inactive
    local label = icon .. ' ' .. name .. '  '
    table.insert(parts, label)
    if is_active then
      table.insert(hls, { col1 = col, col2 = col + #label, hl_group = 'TabLineSel' })
    else
      table.insert(hls, { col1 = col, col2 = col + #label, hl_group = 'TabLine' })
    end
    col = col + #label
  end

  -- 右侧标题
  local title = 'Pack'
  local padding = string.rep(' ', math.max(1, 50 - col - #title))
  table.insert(parts, padding .. title)
  table.insert(hls, { col1 = col + #padding, col2 = col + #padding + #title, hl_group = 'Title' })

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

  table.insert(lines, string.format('  Total: %d plugins | %d loaded | %d lazy | %d missing', #all_specs, loaded_count, lazy_count, missing_count))
  table.insert(highlights, { line = #lines - 1, col1 = 0, col2 = -1, hl_group = 'Title' })
  table.insert(lines, '')

  for _, spec in ipairs(all_specs) do
    local is_loaded = registry.is_loaded(spec.name)
    local is_installed = installed[spec.name] ~= nil
    local icon, hl_group

    if not is_installed then
      icon = '✗'
      hl_group = 'DiagnosticError'
    elseif is_loaded then
      icon = '●'
      hl_group = 'DiagnosticOk'
    else
      icon = '○'
      hl_group = 'DiagnosticWarn'
    end

    local author = parse_author(spec.src)
    local version = is_installed and installed[spec.name].version and tostring(installed[spec.name].version) or ''
    if not is_installed then version = 'MISSING' end

    local ms = cache.load_times[spec.name]
    local time_str = ms and string.format('%.1fms', ms) or '-'

    local line_text = string.format('  %s %-30s %-12s %-8s %s', icon, spec.name, author, version, time_str)
    table.insert(lines, line_text)
    table.insert(highlights, { line = #lines - 1, col1 = 2, col2 = 3, hl_group = hl_group })
    if not is_installed then
      local miss_start = string.len(string.format('  %s %-30s %-12s ', icon, spec.name, author))
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
    local bar = string.rep('█', bar_len)
    local line_text = string.format('  %2d. %-30s %6.1fms  %s', i, entry.name, entry.ms, bar)
    table.insert(lines, line_text)
  end

  if #sorted == 0 then table.insert(lines, '  No load time data yet') end

  return lines, highlights
end

--- 获取插件安装路径
---@param name string
---@return string?
local function get_plugin_path(name)
  local pack_info = vim.pack.get(nil, { info = true }) or {}
  for _, p in ipairs(pack_info) do
    if p.spec and p.spec.name == name then return p.path end
  end
  return nil
end

--- 获取当前版本号
---@param path string
---@return string
local function git_current_version(path)
  local obj = vim.system({ 'git', 'describe', '--tags', '--abbrev=0' }, { cwd = path, text = true }):wait()
  if obj.code == 0 and obj.stdout then return vim.trim(obj.stdout) end
  local obj2 = vim.system({ 'git', 'rev-parse', '--short', 'HEAD' }, { cwd = path, text = true }):wait()
  if obj2.code == 0 and obj2.stdout then return vim.trim(obj2.stdout) end
  return '?'
end

--- 获取缺失插件列表
---@return table[] 每项: { name, src }
local function get_missing_plugins()
  local installed = {}
  for _, p in ipairs(vim.pack.get(nil, { info = true }) or {}) do
    if p.spec and p.spec.name then installed[p.spec.name] = true end
  end

  local missing = {}
  for _, spec in ipairs(registry.get_all_specs()) do
    if not installed[spec.name] then table.insert(missing, { name = spec.name, src = spec.src }) end
  end
  return missing
end

-- 缓存检查结果
local update_cache = {
  updatable = nil,
  missing = nil,
  checked_at = 0,
  checking = false,
}

local function render_update()
  local lines = {}
  local highlights = {}

  local updatable = update_cache.updatable or {}
  local missing = update_cache.missing or {}

  if update_cache.checking then
    -- 异步检查中
    table.insert(lines, '  Checking for updates...')
    table.insert(highlights, { line = #lines - 1, col1 = 0, col2 = -1, hl_group = 'Title' })
    table.insert(lines, '')
    table.insert(lines, '  Please wait, fetching remote info for each plugin.')
  elseif not state.is_busy then
    table.insert(lines, string.format('  %d updates available | %d missing', #updatable, #missing))
    table.insert(highlights, { line = #lines - 1, col1 = 0, col2 = -1, hl_group = 'Title' })
    table.insert(lines, '')

    for _, u in ipairs(updatable) do
      local author = parse_author(registry.get_spec(u.name) and registry.get_spec(u.name).src or '')
      local line_text = string.format('  ○ %-30s %-12s %s → %s', u.name, author, u.current_ver, u.new_ver)
      table.insert(lines, line_text)
      table.insert(highlights, { line = #lines - 1, col1 = 2, col2 = 3, hl_group = 'DiagnosticWarn' })
    end

    for _, m in ipairs(missing) do
      local line_text = string.format('  ✗ %-30s (not installed)', m.name)
      table.insert(lines, line_text)
      table.insert(highlights, { line = #lines - 1, col1 = 2, col2 = 3, hl_group = 'DiagnosticError' })
    end

    if #updatable == 0 and #missing == 0 then table.insert(lines, '  All plugins are up to date') end
  end

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
    local line_text = string.format('  ○ %-30s %-12s %s', p.name, author, version)
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
  table.insert(lines, string.rep('─', 50))

  -- Tab 内容
  local content_lines, content_hls
  if state.tab == 'Plugins' then
    content_lines, content_hls = render_plugins()
  elseif state.tab == 'Profile' then
    content_lines, content_hls = render_profile()
  elseif state.tab == 'Update' then
    content_lines, content_hls = render_update()
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
    help_line = '  [S]ync  [X] Remove  [1-4] Tab  [?] Help  [q] Close'
  elseif state.tab == 'Update' then
    if state.is_busy then
      help_line = '  [C] Cancel              [1-4] Tab  [q] Close'
    else
      help_line = '  [U] Update all  [S]ync  [1-4] Tab  [?] Help  [q] Close'
    end
  elseif state.tab == 'Clean' then
    help_line = '  [c] Clean all  [X] Remove  [1-4] Tab  [?] Help  [q] Close'
  elseif state.tab == 'Profile' then
    help_line = '  [R] Refresh  [1-4] Tab  [?] Help  [q] Close'
  else
    help_line = '  [1-4] Tab  [?] Help  [q] Close'
  end
  table.insert(lines, help_line)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- 应用高亮
  for _, h in ipairs(highlights) do
    pcall(vim.hl.range, buf, NS, h.hl_group, { h.line, h.col1 }, { h.line, h.col2 }, { inclusive = false, priority = 100 })
  end

  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
end

--- 检查更新（异步，带缓存，5 分钟有效期）
function M.check_updates(force)
  local now = os.time()
  if not force and update_cache.checked_at > 0 and (now - update_cache.checked_at) < 300 then return end

  if update_cache.checking then return end
  update_cache.checking = true

  -- 先计算缺失插件（同步，很快）
  update_cache.missing = get_missing_plugins()
  update_cache.updatable = {}

  -- 显示 checking 状态
  render()

  -- 异步串行检查每个已安装插件
  local all_specs = registry.get_all_specs()
  local idx = 0

  local function check_next()
    idx = idx + 1
    while idx <= #all_specs do
      local spec = all_specs[idx]
      local path = get_plugin_path(spec.name)
      if not path then
        idx = idx + 1
      else
        break
      end
    end

    if idx > #all_specs then
      -- 所有插件检查完毕
      table.sort(update_cache.updatable, function(a, b) return a.name < b.name end)
      update_cache.checked_at = os.time()
      update_cache.checking = false
      render()
      return
    end

    local spec = all_specs[idx]
    local path = get_plugin_path(spec.name)

    vim.system({ 'git', 'fetch' }, { cwd = path, text = true, timeout = 30000 }, function(fetch_result)
      if fetch_result.code ~= 0 then
        vim.schedule(check_next)
        return
      end

      vim.system({ 'git', 'rev-parse', 'HEAD' }, { cwd = path, text = true }, function(local_result)
        vim.system({ 'git', 'rev-parse', '@{u}' }, { cwd = path, text = true }, function(remote_result)
          if local_result.code == 0 and remote_result.code == 0 then
            local local_rev = vim.trim(local_result.stdout)
            local remote_rev = vim.trim(remote_result.stdout)
            if local_rev ~= remote_rev then
              table.insert(update_cache.updatable, {
                name = spec.name,
                path = path,
                current_ver = local_rev:sub(1, 7),
                new_ver = remote_rev:sub(1, 7),
              })
            end
          end

          vim.schedule(check_next)
        end)
      end)
    end)
  end

  vim.schedule(check_next)
end

--- 切换 Tab
---@param tab_name string
local function switch_tab(tab_name)
  if not vim.tbl_contains(TABS, tab_name) then return end
  state.tab = tab_name
  render()
  -- 切换到 Update Tab 时检查更新
  if tab_name == 'Update' then M.check_updates() end
end

--- 获取光标所在行的插件名
---@return string?
local function get_cursor_plugin_name()
  if not is_open() then return nil end
  local line = vim.api.nvim_win_get_cursor(state.win)[1]
  -- 跳过 Tab 栏(2 行) + 统计行 + 空行 = 从第 4 行开始是插件列表
  if line < 4 then return nil end
  local text = vim.api.nvim_get_current_line()
  -- 匹配插件名: 行格式为 "  ● name ..."
  local name = text:match('^  [●○✗] (%S+)')
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

  -- Tab 切换
  for i, name in ipairs(TABS) do
    vim.api.nvim_buf_set_keymap(buf, 'n', tostring(i), '', {
      nowait = true,
      noremap = true,
      silent = true,
      callback = function() switch_tab(name) end,
    })
  end

  -- 帮助
  vim.api.nvim_buf_set_keymap(buf, 'n', '?', '', {
    nowait = true,
    noremap = true,
    silent = true,
    callback = function() vim.notify('Pack Manager: [1-4] Switch tab  [S] Sync  [q] Close  [?] Help', vim.log.levels.INFO) end,
  })

  -- 取消
  vim.api.nvim_buf_set_keymap(buf, 'n', 'C', '', {
    nowait = true,
    noremap = true,
    silent = true,
    callback = function()
      if state.is_busy then M.do_cancel() end
    end,
  })

  -- Sync
  vim.api.nvim_buf_set_keymap(buf, 'n', 'S', '', {
    nowait = true,
    noremap = true,
    silent = true,
    callback = function()
      if not state.is_busy then M.do_sync() end
    end,
  })

  -- Update all
  vim.api.nvim_buf_set_keymap(buf, 'n', 'U', '', {
    nowait = true,
    noremap = true,
    silent = true,
    callback = function()
      if not state.is_busy and state.tab == 'Update' then M.do_update() end
    end,
  })

  -- Update selected plugin (Update Tab)
  vim.api.nvim_buf_set_keymap(buf, 'n', 'u', '', {
    nowait = true,
    noremap = true,
    silent = true,
    callback = function()
      if not state.is_busy and state.tab == 'Update' then
        local name = get_cursor_plugin_name()
        if name then M.do_update({ name }) end
      end
    end,
  })

  -- Clean all (with double-press confirmation)
  vim.api.nvim_buf_set_keymap(buf, 'n', 'c', '', {
    nowait = true,
    noremap = true,
    silent = true,
    callback = function()
      if state.is_busy then return end
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
  if state.is_busy then return end
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

--- 向面板追加内容行（用于异步进度更新）
---@param text string
---@param hl_group? string
local function append_line(text, hl_group)
  if not is_open() then return end
  local buf = state.buf
  vim.bo[buf].modifiable = true

  local line_count = vim.api.nvim_buf_line_count(buf)
  local insert_at = line_count - 1 -- 在底部帮助行之前插入

  vim.api.nvim_buf_set_lines(buf, insert_at, insert_at, false, { text })
  if hl_group then pcall(vim.hl.range, buf, NS, hl_group, { insert_at, 0 }, { insert_at, #text }, { inclusive = false, priority = 100 }) end

  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true

  if is_open() then vim.api.nvim_win_set_cursor(state.win, { insert_at + 1, 0 }) end
end

--- 替换面板中的某一行
---@param line_idx number 0-based
---@param text string
---@param hl_group? string
local function replace_line(line_idx, text, hl_group)
  if not is_open() then return end
  local buf = state.buf
  vim.bo[buf].modifiable = true

  vim.api.nvim_buf_set_lines(buf, line_idx, line_idx + 1, false, { text })
  vim.api.nvim_buf_clear_namespace(buf, NS, line_idx, line_idx + 1)
  if hl_group then pcall(vim.hl.range, buf, NS, hl_group, { line_idx, 0 }, { line_idx, #text }, { inclusive = false, priority = 100 }) end

  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
end

--- 串行执行异步 git 操作
---@param items table[] 每项: { name, action: 'update'|'install', path?, src? }
---@param on_complete? function
local function run_async_queue(items, on_complete)
  if #items == 0 then
    if on_complete then on_complete() end
    return
  end

  state.is_busy = true
  state.cancelled = false
  local completed = 0
  local failed = 0
  local total = #items

  render()

  local function update_header()
    local action_label = items[1].action == 'install' and 'Installing' or 'Updating'
    replace_line(2, string.format('  %s... %d/%d', action_label, completed, total), 'Title')
  end

  update_header()

  local function process_next(idx)
    if idx > total or state.cancelled then
      state.is_busy = false
      if state.cancelled then append_line('  Cancelled', 'DiagnosticWarn') end
      update_cache.checked_at = 0
      render()
      if on_complete then on_complete(completed, failed) end
      return
    end

    local item = items[idx]
    local cmd, args

    if item.action == 'install' then
      cmd = 'git'
      args = { 'clone', item.src, item.path }
      append_line(string.format('  ● %s  Cloning...', item.name), 'DiagnosticInfo')
    else
      cmd = 'git'
      args = { 'pull' }
      append_line(string.format('  ● %s  Updating...', item.name), 'DiagnosticInfo')
    end

    local start_line = vim.api.nvim_buf_line_count(state.buf) - 2

    vim.system({ cmd, unpack(args) }, {
      cwd = item.path,
      timeout = 60000,
    }, function(result)
      completed = completed + 1

      if result.code ~= 0 then
        failed = failed + 1
        local err_msg = result.stderr and vim.trim(result.stderr) or 'Unknown error'
        replace_line(start_line, string.format('  ✗ %s  Failed: %s', item.name, err_msg:sub(1, 40)), 'DiagnosticError')
      else
        local new_ver = git_current_version(item.path or vim.fn.stdpath('data') .. '/pack/packages/opt/' .. item.name)
        replace_line(start_line, string.format('  ✓ %s  Done (%s)', item.name, new_ver), 'DiagnosticOk')
      end

      local action_label = items[1].action == 'install' and 'Installing' or 'Updating'
      replace_line(2, string.format('  %s... %d/%d', action_label, completed, total), 'Title')

      vim.schedule(function() process_next(idx + 1) end)
    end)
  end

  process_next(1)
end

--- 更新指定插件（空闲状态调用）
---@param names? string[] nil 表示全部可更新
function M.do_update(names)
  if state.is_busy then return end

  local targets = update_cache.updatable or {}
  if names then targets = vim.tbl_filter(function(u) return vim.tbl_contains(names, u.name) end, targets) end

  if #targets == 0 then
    vim.notify('No plugins to update', vim.log.levels.INFO)
    return
  end

  local items = vim.tbl_map(function(u) return { name = u.name, action = 'update', path = u.path } end, targets)

  run_async_queue(
    items,
    function(completed, failed)
      vim.notify(string.format('Update complete: %d updated, %d failed', completed - failed, failed), failed > 0 and vim.log.levels.WARN or vim.log.levels.INFO)
    end
  )
end

--- 安装缺失插件
---@param names? string[] nil 表示全部缺失
function M.do_install(names)
  if state.is_busy then return end

  local targets = names or vim.tbl_map(function(m) return m.name end, update_cache.missing or {})

  local items = {}
  for _, name in ipairs(targets) do
    local spec = registry.get_spec(name)
    if spec then
      local install_path = vim.fn.stdpath('data') .. '/pack/packages/opt/' .. name
      table.insert(items, { name = name, action = 'install', src = spec.src, path = install_path })
    end
  end

  if #items == 0 then
    vim.notify('No plugins to install', vim.log.levels.INFO)
    return
  end

  run_async_queue(items, function(completed, failed)
    -- 注册并 source 新安装的插件
    for _, item in ipairs(items) do
      local spec = registry.get_spec(item.name)
      if spec then
        local pack_spec = { src = spec.src, name = spec.name }
        if spec.version then pack_spec.version = spec.version end
        -- 先注册（不带 load=false 使其加入 runtimepath）
        vim.pack.add({ pack_spec })
      end
    end

    if failed == 0 then
      vim.notify(string.format('Installed %d plugins, restart recommended', completed), vim.log.levels.INFO)
    else
      vim.notify(string.format('Install complete: %d installed, %d failed', completed - failed, failed), vim.log.levels.WARN)
    end
  end)
end

--- Sync: 安装缺失 + 更新全部
function M.do_sync()
  if state.is_busy then return end
  M.check_updates(true)

  local missing = update_cache.missing or {}
  local updatable = update_cache.updatable or {}

  if #missing == 0 and #updatable == 0 then
    vim.notify('All plugins are in sync', vim.log.levels.INFO)
    return
  end

  local all_items = {}

  for _, m in ipairs(missing) do
    local spec = registry.get_spec(m.name)
    if spec then
      local install_path = vim.fn.stdpath('data') .. '/pack/packages/opt/' .. m.name
      table.insert(all_items, { name = m.name, action = 'install', src = spec.src, path = install_path })
    end
  end

  for _, u in ipairs(updatable) do
    table.insert(all_items, { name = u.name, action = 'update', path = u.path })
  end

  run_async_queue(
    all_items,
    function(completed, failed)
      vim.notify(string.format('Sync complete: %d done, %d failed', completed - failed, failed), failed > 0 and vim.log.levels.WARN or vim.log.levels.INFO)
    end
  )
end

--- 取消当前操作
function M.do_cancel() state.cancelled = true end

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
  -- 打开时检查更新
  if state.tab == 'Update' then M.check_updates() end
end

--- 注册 :Pack 命令
function M.register_commands()
  vim.api.nvim_create_user_command('Pack', function(opts)
    local tab = vim.trim(opts.args or '')
    ---@diagnostic disable-next-line: cast-local-type
    if tab == '' then tab = nil end
    M.open(tab)
  end, {
    nargs = '?',
    complete = function() return TABS end,
    desc = 'Open pack manager panel',
  })
end

return M
