local M = {}

local Terminal = require('toggleterm.terminal').Terminal
local api = vim.api

-- 命名单实例浮动终端(如 RUN),保持原逻辑
local terminals = {}

-- 默认浮动终端(<C-t>)的多 tab 集合
local tabs = {} -- 有序 Terminal 对象数组
local active_idx = nil
local term_timer = nil -- ensure_terminal 的轮询 timer, 同一时刻只保留一个, 避免并发抢焦点
local sync_timer = nil -- tab 栏与终端窗口的状态同步 timer

-- 独立的 tab 栏浮动窗口(带边框, 在终端窗口正上方)
local tabbar_win = nil
local tabbar_buf = nil
local tabbar_ns = api.nvim_create_namespace('term_tabbar')

-- 浮动终端可见性变化时的回调: 终端打开时绑定 tab 管理快捷键, 隐藏时解绑
local open_hook, close_hook
local maps_bound = false

local tabmode = { active = false, suspended = false } -- tab 管理子模式状态(子模式段与 _render_tabbar 共享)
local exit_tabmode -- 前向声明: 子模式段赋值, 供 sync_maps 在终端隐藏时调用
local suspend_tabmode_buffer_maps -- tab 切换后挂起新终端 buffer 中与子模式冲突的局部映射

local function term_is_open(t)
  if not t or not t.window or not api.nvim_win_is_valid(t.window) then return false end
  return t:is_open()
end

-- 浮动终端是否可见(当前 tab 窗口有效且处于打开状态)
local function term_visible()
  local t = active_idx ~= nil and tabs[active_idx] or nil
  return term_is_open(t)
end

-- 根据可见性绑定/解绑 tab 管理快捷键(仅在状态真正切换时触发, 避免重复 set/del)
local function sync_maps()
  local vis = term_visible()
  if vis and not maps_bound then
    maps_bound = true
    if open_hook then open_hook() end
  elseif not vis and maps_bound then
    maps_bound = false
    if tabmode.active then exit_tabmode() end -- 终端隐藏时退出子模式, 避免单键映射残留
    if close_hook then close_hook() end
  end
end

-- 由 toggleterm 插件注册: 终端可见时调用 open_fn, 隐藏时调用 close_fn
function M.set_hooks(open_fn, close_fn)
  open_hook = open_fn
  close_hook = close_fn
end

local FLOAT_OPTS = { width = 120, height = 36, border = 'rounded' }
-- ensure_terminal 轮询上限(次), 每 10ms 一次 → 最多约 200ms
local MAX_ENSURE_ATTEMPTS = 20

---------------------------------------------------------------------------
-- 命名单实例终端(给 RUN 等用)
---------------------------------------------------------------------------
local function cleanup_artifacts(artifacts, attempt)
  if not artifacts or #artifacts == 0 then return end
  local pending = {}
  for _, artifact in ipairs(artifacts) do
    local deleted = artifact.recursive and vim.fn.delete(artifact.path, 'rf') or vim.fn.delete(artifact.path)
    if deleted ~= 0 and vim.uv.fs_stat(artifact.path) then pending[#pending + 1] = artifact end
  end
  attempt = (attempt or 0) + 1
  if #pending > 0 and attempt < 20 then vim.defer_fn(function() cleanup_artifacts(pending, attempt) end, 50) end
end

local function cleanup_terminal(t)
  local artifacts = t and t._cleanup_artifacts
  if not artifacts then return end
  t._cleanup_artifacts = nil
  vim.schedule(function() cleanup_artifacts(artifacts) end)
end

function M.floaterm(name, cmd, close, opts, cleanup)
  -- 销毁同名旧终端(关闭窗口 + 停止后台进程), 保证每次调用都重新执行命令
  -- 否则 close_on_exit=false 会复用已退出的 buffer, 仅重新显示而不重跑; 命令变化时也会泄漏旧进程
  local prev = terminals[name]
  if prev then
    if prev:is_open() then prev:close() end
    if prev.shutdown then pcall(prev.shutdown, prev) end
    cleanup_terminal(prev)
    terminals[name] = nil
  end
  terminals[name] = Terminal:new({
    cmd = cmd ~= '' and cmd or nil,
    display_name = name,
    dir = 'git_dir',
    close_on_exit = close or false,
    float_opts = opts,
    hidden = true,
    on_open = function(_) vim.cmd('startinsert!') end,
    on_exit = function(t) cleanup_terminal(t) end,
  })
  terminals[name]._cleanup_artifacts = cleanup

  if name == 'RUN' then terminals[name].dir = vim.fn.fnamemodify(vim.fn.expand('%'), ':p:h') end

  terminals[name]:toggle()
end

---------------------------------------------------------------------------
-- tab 栏: 独立的带边框浮动窗口
---------------------------------------------------------------------------

-- 停止状态同步轮询
local function stop_sync()
  if sync_timer and not sync_timer:is_closing() then
    sync_timer:stop()
    sync_timer:close()
  end
  sync_timer = nil
end

-- 启动状态同步轮询: tab 栏显示期间, 若没有任何 tab 终端窗口仍有效(被外部关闭/失焦/diff 界面等), 同步隐藏 tab 栏
local function start_sync()
  if sync_timer then return end -- 已在运行
  local timer = vim.uv.new_timer()
  if not timer then return end
  sync_timer = timer
  timer:start(
    100,
    100,
    vim.schedule_wrap(function()
      if not tabbar_win or not api.nvim_win_is_valid(tabbar_win) then return stop_sync() end
      for _, t in ipairs(tabs) do
        if t.window and api.nvim_win_is_valid(t.window) and t:is_open() then return end
      end
      M._close_tabbar()
      sync_maps()
    end)
  )
end

function M._close_tabbar()
  stop_sync()
  if tabbar_win and api.nvim_win_is_valid(tabbar_win) then api.nvim_win_close(tabbar_win, true) end
  tabbar_win = nil
end

function M._render_tabbar()
  if not tabbar_buf or not api.nvim_buf_is_valid(tabbar_buf) then return end
  api.nvim_buf_clear_namespace(tabbar_buf, tabbar_ns, 0, -1)
  api.nvim_buf_set_lines(tabbar_buf, 0, -1, false, { '' })
  local win_width = (tabbar_win and api.nvim_win_is_valid(tabbar_win)) and api.nvim_win_get_width(tabbar_win) or 100
  -- 预计算每个 tab 的标签文本, 避免在扩展循环里重复 string.format
  local labels = {}
  local label_widths = {}
  for i = 1, #tabs do
    labels[i] = string.format(' %d %s ', i, tabs[i].display_name or 'term')
    label_widths[i] = vim.fn.strdisplaywidth(labels[i])
  end
  -- 以 active 为中心向两侧扩展, 受 tab 栏宽度约束; 为溢出标记 ‹ › 预留空间
  local function compute_range(budget)
    local l, r = active_idx, active_idx
    local total = label_widths[active_idx]
    while true do
      local added = false
      if r + 1 <= #tabs and total + 1 + label_widths[r + 1] <= budget then
        r = r + 1
        total = total + 1 + label_widths[r]
        added = true
      end
      if l - 1 >= 1 and total + 1 + label_widths[l - 1] <= budget then
        l = l - 1
        total = total + 1 + label_widths[l]
        added = true
      end
      if not added then break end
    end
    return l, r
  end
  -- 子模式激活时, 在 tab 栏最左侧显示醒目标记, 并预留其占用宽度
  local mode_reserve = (tabmode and tabmode.active) and 6 or 0
  local budget = win_width - mode_reserve
  local left, right = compute_range(budget)
  local reserve = (left > 1 and 2 or 0) + (right < #tabs and 2 or 0)
  if reserve > 0 then
    left, right = compute_range(budget - reserve)
  end
  local segments = {}
  if mode_reserve > 0 then
    table.insert(segments, { ' TAB ', 'TermTabMode' })
    table.insert(segments, { '│', 'TermTabSep' })
  end
  if left > 1 then table.insert(segments, { '‹ ', 'TermTabSep' }) end
  for i = left, right do
    if i ~= left then table.insert(segments, { '│', 'TermTabSep' }) end
    table.insert(segments, { labels[i], (i == active_idx) and 'TermTabActive' or 'TermTab' })
  end
  if right < #tabs then table.insert(segments, { ' ›', 'TermTabSep' }) end
  api.nvim_buf_set_extmark(tabbar_buf, tabbar_ns, 0, 0, { virt_text = segments, virt_text_pos = 'inline' })
end

-- 根据 term 窗口位置在其正上方打开/复用 tab 栏窗口
function M._open_tabbar(term)
  local win = term.window
  -- 用绝对位置定位, 让 tab 栏底部 border 与终端顶部 border 重叠, 视觉合成单条分割线
  local pos = api.nvim_win_get_position(win)
  local prow, pcol = pos[1], pos[2]
  local width = api.nvim_win_get_width(win)
  local win_opts = {
    relative = 'editor',
    row = math.max(0, prow - 2), -- tab 内容在 prow-2, 底部 border 落在 prow-1 = 终端顶部 border
    col = pcol,
    width = width,
    height = 1,
    -- 顶部圆角; 底部 ─ 作为与终端的分隔线(覆盖终端顶部 border)
    border = { '╭', '─', '╮', '│', '┤', '─', '├', '│' },
    zindex = 100, -- 盖在终端顶部 border 之上, 使分隔线连续
    style = 'minimal',
    focusable = false,
    noautocmd = true,
  }
  if not tabbar_buf or not api.nvim_buf_is_valid(tabbar_buf) then
    tabbar_buf = api.nvim_create_buf(false, true)
    vim.bo[tabbar_buf].buftype = 'nofile'
  end
  if not tabbar_win or not api.nvim_win_is_valid(tabbar_win) then
    tabbar_win = api.nvim_open_win(tabbar_buf, false, win_opts)
  else
    api.nvim_win_set_config(tabbar_win, win_opts)
  end
  M._render_tabbar()
  start_sync()
end

-- 编辑器尺寸变化时 toggleterm 会重居中终端, tab 栏需跟随重新定位, 否则与终端错位
vim.api.nvim_create_autocmd('VimResized', {
  callback = function()
    -- ToggleTerm 的 buffer-local VimResized 会在本 autocmd 之后重居中终端, 延后一轮再读取最终位置。
    vim.schedule(function()
      if not (tabbar_win and api.nvim_win_is_valid(tabbar_win)) then return end
      local t = active_idx and tabs[active_idx]
      if t and t.window and api.nvim_win_is_valid(t.window) and t:is_open() then M._open_tabbar(t) end
    end)
  end,
})

local function schedule_visibility_sync()
  vim.schedule(function()
    if not term_visible() then M._close_tabbar() end
    sync_maps()
  end)
end

-- 终端窗口被 :close / nvim_win_close 等方式关闭时同步状态
-- (单 tab 时没有 tab 栏 timer 兜底, 否则子模式映射与 <A-o> 会残留)
vim.api.nvim_create_autocmd('WinClosed', {
  callback = function(args)
    local win = tonumber(args.match)
    if not win then return end
    for _, t in ipairs(tabs) do
      if t.window == win then
        schedule_visibility_sync()
        return
      end
    end
  end,
})

-- 窗口未关闭但 terminal buffer 被 :enew / :buffer / nvim_win_set_buf 替换时也要同步状态
vim.api.nvim_create_autocmd('BufWinLeave', {
  callback = function(args)
    for _, t in ipairs(tabs) do
      if t.bufnr == args.buf then
        schedule_visibility_sync()
        return
      end
    end
  end,
})

-- 依据当前 tab 数量决定 tab 栏开关: >=2 显示并刷新, 否则关闭
local function refresh_tabbar()
  if #tabs >= 2 then
    local t = tabs[active_idx]
    if t and t.window and api.nvim_win_is_valid(t.window) and t:is_open() then M._open_tabbar(t) end
  else
    M._close_tabbar()
  end
end

---------------------------------------------------------------------------
-- tab 生命周期
---------------------------------------------------------------------------

-- 刷新所有已打开 tab 的浮动 border title(把 display_name 的变化同步到窗口边框)
local function update_titles()
  for _, t in ipairs(tabs) do
    if t.window and api.nvim_win_is_valid(t.window) then
      local ok, cfg = pcall(api.nvim_win_get_config, t.window)
      if ok and cfg then
        cfg.title = t.display_name
        pcall(api.nvim_win_set_config, t.window, cfg)
      end
    end
  end
end

-- 统一 tab 命名: 单个为 Term, 多个按位置 Term1..TermN; 保留用户重命名的(custom) tab
local function renumber_tabs()
  for i, t in ipairs(tabs) do
    if not t.custom then t.display_name = (#tabs == 1) and 'Term' or string.format('Term%d', i) end
  end
  update_titles()
end

-- 切换/关闭后用 timer 轮询, 确保目标 tab 获得焦点并进入 terminal 模式
-- (term:close() 会 stopinsert 并可能把焦点改到 origin_window, 单次 schedule 追不上)
local function ensure_terminal(target)
  local expected = tabs[target]
  -- 停止上一个轮询 timer, 避免连续操作时多个 timer 并发互相抢焦点
  if term_timer and not term_timer:is_closing() then
    term_timer:stop()
    term_timer:close()
  end
  term_timer = nil
  local timer = vim.uv.new_timer()
  if not timer then
    vim.schedule(function()
      if tabs[active_idx] == expected and term_is_open(expected) then
        api.nvim_set_current_win(expected.window)
        vim.cmd('startinsert!')
      end
    end)
    return
  end
  term_timer = timer
  local attempts = 0
  timer:start(
    10,
    10,
    vim.schedule_wrap(function()
      attempts = attempts + 1
      local function finish()
        timer:stop()
        if not timer:is_closing() then timer:close() end
        if term_timer == timer then term_timer = nil end
      end
      if attempts > MAX_ENSURE_ATTEMPTS or tabs[active_idx] ~= expected or not term_is_open(expected) then return finish() end
      if api.nvim_get_current_win() ~= expected.window then api.nvim_set_current_win(expected.window) end
      if vim.fn.mode() ~= 't' then
        vim.cmd('startinsert!')
      else
        return finish()
      end
    end)
  )
end

local function on_tab_open() vim.cmd('startinsert!') end

-- 进程退出: 销毁对应 tab; 单个 tab 时整个浮动组销毁, 多个则切到相邻
local function on_tab_exit(t)
  local was_visible = term_visible()
  local was_active = active_idx ~= nil and tabs[active_idx] == t
  vim.schedule(function()
    local idx = nil
    for i, tt in ipairs(tabs) do
      if tt == t then
        idx = i
        break
      end
    end
    if not idx then return end
    if t.shutdown then pcall(t.shutdown, t) end
    table.remove(tabs, idx)
    if #tabs == 0 then
      active_idx = nil
      M._close_tabbar()
      sync_maps()
      return
    end
    -- 调整 active_idx
    if active_idx then
      if idx < active_idx then
        active_idx = active_idx - 1
      elseif idx == active_idx then
        active_idx = math.min(idx, #tabs)
      end
    else
      active_idx = 1
    end
    renumber_tabs()
    if was_visible and was_active then
      M.show(active_idx)
      ensure_terminal(active_idx)
    elseif was_visible then
      refresh_tabbar()
      sync_maps()
    else
      M._close_tabbar()
      sync_maps()
    end
  end)
end

local function make_term()
  return Terminal:new({
    dir = vim.fn.getcwd(),
    hidden = true,
    close_on_exit = true,
    float_opts = FLOAT_OPTS,
    on_open = on_tab_open,
    on_exit = on_tab_exit,
  })
end

-- 只显示第 idx 个 tab, 其余关闭
function M.show(idx)
  if not tabs[idx] then return end
  active_idx = idx
  local expected = tabs[idx]
  -- 先关闭其他 tab(其 close 会 stopinsert/改焦点), 再 open active, 避免刚 startinsert 就被打断
  for i = #tabs, 1, -1 do
    if i ~= idx and tabs[i]:is_open() then tabs[i]:close() end
  end
  if not tabs[idx]:is_open() then tabs[idx]:open() end
  if tabmode.active and suspend_tabmode_buffer_maps then suspend_tabmode_buffer_maps(tabs[idx].bufnr) end
  refresh_tabbar()
  sync_maps()
  -- 切换后确保焦点回到 active tab 并进入 terminal 模式(异步, 等所有窗口操作完成)
  vim.schedule(function()
    if tabs[active_idx] == expected and term_is_open(expected) then
      api.nvim_set_current_win(expected.window)
      vim.cmd('startinsert!')
    end
  end)
end

-- <C-t>: 整个浮动终端组开关
function M.toggle_default()
  if #tabs == 0 then
    M.new_tab()
  elseif tabs[active_idx] and tabs[active_idx]:is_open() then
    tabs[active_idx]:close()
    M._close_tabbar()
  else
    M.show(active_idx or 1)
  end
  sync_maps()
end

-- <A-n> / :TermNew: 新建 tab 并切换过去
function M.new_tab()
  local t = make_term()
  t.custom = false
  table.insert(tabs, t)
  renumber_tabs()
  M.show(#tabs)
end

-- <A-w>: 关闭当前 tab
function M.close_tab()
  if not active_idx or not tabs[active_idx] then return end
  local idx = active_idx
  local t = tabs[idx]
  if t:is_open() then t:close() end
  if t.shutdown then pcall(t.shutdown, t) end
  table.remove(tabs, idx)
  if #tabs == 0 then
    active_idx = nil
    M._close_tabbar()
    sync_maps()
    return
  end
  renumber_tabs()
  active_idx = math.min(idx, #tabs)
  M.show(active_idx)
  ensure_terminal(active_idx)
end

function M.next_tab()
  if #tabs >= 2 then M.show((active_idx or 1) % #tabs + 1) end
end

function M.prev_tab()
  if #tabs >= 2 then M.show(((active_idx or 1) - 2) % #tabs + 1) end
end

function M.goto_tab(n)
  if tabs[n] then M.show(n) end
end

-- <A-r> / :TermRename: 修改当前 tab 名称(便于多 tab 区分功能)
function M.rename_tab(name, on_done)
  if not active_idx or not tabs[active_idx] then
    if on_done then on_done() end
    return
  end
  local target = tabs[active_idx]
  local function apply(n)
    local target_idx = nil
    for i, t in ipairs(tabs) do
      if t == target then
        target_idx = i
        break
      end
    end
    if target_idx and n and n ~= '' then
      target.display_name = n
      target.custom = true
      update_titles()
      refresh_tabbar()
      -- 改名后回到终端 insert
      vim.schedule(function()
        if tabs[active_idx] == target and target.window and api.nvim_win_is_valid(target.window) then
          api.nvim_set_current_win(target.window)
          vim.cmd('startinsert!')
        end
      end)
    end
    if on_done then on_done() end
  end
  if name and name ~= '' then
    apply(name)
  else
    vim.ui.input({ prompt = 'Terminal name: ', default = target.display_name or '' }, apply)
  end
end

---------------------------------------------------------------------------
-- tab 管理子模式: <A-o> 进入, 单键操作(n/w/l/h/r/1-9), <Esc> 或他键退出
---------------------------------------------------------------------------
local TABMODE_SUBKEYS = { 'n', 'w', 'l', 'h', 'r' }

local tabmode_allowed = {}
for _, k in ipairs(TABMODE_SUBKEYS) do
  tabmode_allowed[k] = true
end
for i = 1, 9 do
  tabmode_allowed[tostring(i)] = true
end

-- 子模式会临时覆盖的所有键(子键 + <Esc>); 进入前保存原映射, 退出时逐个恢复
local TABMODE_ALLKEYS = { '<Esc>' }
vim.list_extend(TABMODE_ALLKEYS, TABMODE_SUBKEYS)
for i = 1, 9 do
  TABMODE_ALLKEYS[#TABMODE_ALLKEYS + 1] = tostring(i)
end

local saved_global_maps = nil
local saved_local_maps = nil

local function normalized_lhs(lhs) return vim.fn.keytrans(api.nvim_replace_termcodes(lhs, true, true, true)) end

local function find_map(maps, lhs)
  local normalized = normalized_lhs(lhs)
  for _, m in ipairs(maps) do
    if m.lhs == normalized then return m end
  end
end

local function get_global_map(mode, lhs) return find_map(api.nvim_get_keymap(mode), lhs) end

local function get_buffer_map(bufnr, mode, lhs)
  if not bufnr or not api.nvim_buf_is_valid(bufnr) then return end
  return find_map(api.nvim_buf_get_keymap(bufnr, mode), lhs)
end

-- 恢复指定作用域内的字符串或 Lua callback 映射; bufnr=nil 表示全局映射
local function restore_map(mode, lhs, arg, bufnr)
  local scope = bufnr and { buffer = bufnr } or nil
  pcall(vim.keymap.del, mode, lhs, scope)
  if type(arg) ~= 'table' then return end

  local rhs = arg.callback or arg.rhs
  if rhs == nil or rhs == '' then return end

  local o = { silent = arg.silent == 1, nowait = arg.nowait == 1, expr = arg.expr == 1, remap = arg.noremap == 0 }
  if arg.replace_keycodes ~= nil then o.replace_keycodes = arg.replace_keycodes == 1 end
  if arg.script == 1 then o.script = true end
  if type(arg.desc) == 'string' then o.desc = arg.desc end
  if bufnr then o.buffer = bufnr end
  pcall(vim.keymap.set, mode, lhs, rhs, o)
end

function M.get_global_map(mode, lhs) return get_global_map(mode, lhs) end

function M.restore_global_map(mode, lhs, arg) restore_map(mode, lhs, arg) end

-- 全局子模式映射无法覆盖 buffer-local 映射。进入某个 buffer 时先暂存并删除冲突映射,
-- 退出子模式后按原 buffer 恢复, 避免错误地把 maparg().buffer=1 当作 buffer id。
suspend_tabmode_buffer_maps = function(bufnr)
  if not bufnr or not api.nvim_buf_is_valid(bufnr) then return end
  local local_maps = saved_local_maps
  if not local_maps or local_maps[bufnr] then return end
  local entries = {}
  local_maps[bufnr] = entries
  for _, lhs in ipairs(TABMODE_ALLKEYS) do
    for _, mode in ipairs({ 'n', 't' }) do
      local original = get_buffer_map(bufnr, mode, lhs)
      if original then
        entries[#entries + 1] = { mode = mode, lhs = lhs, map = original }
        pcall(vim.keymap.del, mode, lhs, { buffer = bufnr })
      end
    end
  end
end

-- 退出子模式: 恢复进入前保存的原映射(而非直接 del, 避免删除用户既有映射如 <Esc> nohlsearch)
function exit_tabmode()
  if not tabmode.active then return end
  tabmode.active = false
  if saved_global_maps then
    for mk, arg in pairs(saved_global_maps) do
      restore_map(mk:sub(1, 1), mk:sub(2), arg)
    end
    saved_global_maps = nil
  end
  if saved_local_maps then
    for bufnr, entries in pairs(saved_local_maps) do
      if api.nvim_buf_is_valid(bufnr) then
        for _, entry in ipairs(entries) do
          restore_map(entry.mode, entry.lhs, entry.map, bufnr)
        end
      end
    end
    saved_local_maps = nil
  end
  refresh_tabbar() -- 清除 tab 栏的子模式标记
end

-- 包装 tab 操作: 执行后若终端不再可见则退出子模式, 否则留在子模式以便连按
local function tabmode_action(fn)
  return function()
    fn()
    if not term_visible() then exit_tabmode() end
  end
end

-- <A-o>: 进入 tab 管理子模式(无超时, 直到 <Esc> 或非命令键退出)
function M.enter_tabmode()
  if not term_visible() or tabmode.active then return end
  -- 只保存真正会被覆盖的全局映射; buffer-local 映射按准确 bufnr 单独挂起
  saved_global_maps = {}
  saved_local_maps = {}
  for _, lhs in ipairs(TABMODE_ALLKEYS) do
    for _, mode in ipairs({ 'n', 't' }) do
      saved_global_maps[mode .. lhs] = get_global_map(mode, lhs) or false
    end
  end
  tabmode.active = true
  suspend_tabmode_buffer_maps(api.nvim_get_current_buf())
  local map = vim.keymap.set
  map({ 'n', 't' }, 'n', tabmode_action(M.new_tab), { silent = true, nowait = true })
  map({ 'n', 't' }, 'w', tabmode_action(M.close_tab), { silent = true, nowait = true })
  map({ 'n', 't' }, 'l', tabmode_action(M.next_tab), { silent = true, nowait = true })
  map({ 'n', 't' }, 'h', tabmode_action(M.prev_tab), { silent = true, nowait = true })
  -- r: rename 会弹 input, 期间暂停 on_key 退出, input 关闭后回到子模式
  map({ 'n', 't' }, 'r', function()
    tabmode.suspended = true
    M.rename_tab(nil, function()
      tabmode.suspended = false
      if not term_visible() then exit_tabmode() end
    end)
  end, { silent = true, nowait = true })
  for i = 1, 9 do
    map({ 'n', 't' }, tostring(i), tabmode_action(function() M.goto_tab(i) end), { silent = true, nowait = true })
  end
  map({ 'n', 't' }, '<Esc>', exit_tabmode, { silent = true, nowait = true, desc = 'Exit tab mode' })
  refresh_tabbar() -- tab 栏显示子模式标记
  vim.notify('Tab mode  n:new  w:close  l/h:next·prev  r:rename  1-9:goto  Esc:exit', vim.log.levels.INFO, { title = 'Terminal' })
end

-- 子模式期间按下任意非命令单字符键(含 Unicode)也退出; 方向键/功能键等特殊键直接发给终端,
-- 也借此过滤掉 toggleterm 切换终端时产生的内部特殊按键事件; 用独立 ns_id 避免覆盖 resize 的 on_key
vim.on_key(function(key)
  if not tabmode.active or tabmode.suspended then return end
  if vim.fn.strchars(key) == 1 and not tabmode_allowed[key] then vim.schedule(exit_tabmode) end
end, api.nvim_create_namespace('term_tabmode'))

---------------------------------------------------------------------------
-- 运行当前文件(RUN 终端)
---------------------------------------------------------------------------
function M.runFile()
  vim.cmd('w')
  local ft = vim.api.nvim_eval('&ft')
  local file = vim.fn.expand('%:p')
  local is_win = require('utils').platform.is_win
  local function quote(value)
    if is_win then return "'" .. value:gsub("'", "''") .. "'" end
    return vim.fn.shellescape(value)
  end
  local function posix_quote(value) return "'" .. value:gsub("'", "'\\''") .. "'" end
  -- Terminal.cmd 最终仍由 Neovim 的 &shell 解析。Windows 使用 EncodedCommand 显式进入 PowerShell,
  -- 避免默认 cmd.exe 误解析单引号、&、% 等 PowerShell 命令字符。
  local function launch(command, cleanup)
    if is_win then
      local utf16 = vim.fn.iconv(command, 'utf-8', 'utf-16le')
      command = 'pwsh.exe -NoLogo -NoProfile -EncodedCommand ' .. vim.base64.encode(utf16)
    end
    M.floaterm('RUN', command, nil, nil, cleanup)
  end
  local function launch_posix(command, cleanup)
    local script = vim.fn.tempname() .. '.sh'
    cleanup = cleanup or {}
    cleanup[#cleanup + 1] = { path = script }
    local trap_cleanup = [=[trap 'rm -f -- "$0"' 0]=]
    local written = vim.fn.writefile({ '#!/bin/sh', trap_cleanup, command }, script)
    if written ~= 0 then
      cleanup_artifacts(cleanup)
      vim.notify('无法创建临时运行脚本: ' .. script, vim.log.levels.ERROR, { title = 'Terminal' })
      return
    end
    launch('sh ' .. vim.fn.shellescape(script), cleanup)
  end
  -- run_cmd 模板: 含 {file} 则替换为转义后的文件路径(用函数 replacement, 避免文件名/命令中的特殊字符被误解析), 否则追加路径
  local function build_cmd(template)
    local f = quote(file)
    if template:find('{file}', 1, true) then return (template:gsub('{file}', function() return f end)) end
    return template .. ' ' .. f
  end

  local run_cmd = vim.tbl_extend('force', {
    javascript = 'node',
    typescript = 'ts-node',
    html = 'firefox',
    python = 'python3',
    go = 'go run',
    sh = 'bash',
    lua = 'lua',
  }, require('settings').file.run_cmd or {})

  if run_cmd[ft] then
    launch(build_cmd(run_cmd[ft]))
  elseif ft == 'markdown' then
    vim.cmd('MarkdownPreview')
  elseif ft == 'java' then
    -- 仅支持无 package 的单文件; package 项目应使用 JavaRunMain 或自定义 file.run_cmd.java
    for _, line in ipairs(api.nvim_buf_get_lines(0, 0, -1, false)) do
      if line:match('^%s*package%s+[%w_%.]+%s*;') then
        vim.notify('带 package 的 Java 文件不支持 <leader>rf; 请使用 :JavaRunMain 或配置 file.run_cmd.java', vim.log.levels.WARN, { title = 'Terminal' })
        return
      end
    end
    local out_dir = vim.fn.tempname()
    if vim.fn.mkdir(out_dir, 'p') == 0 then
      vim.notify('无法创建 Java 临时编译目录: ' .. out_dir, vim.log.levels.ERROR, { title = 'Terminal' })
      return
    end
    local cleanup = { { path = out_dir, recursive = true } }
    if is_win then
      local command = string.format(
        'javac -d %s %s; $termRunStatus = if ($?) { $LASTEXITCODE } else { 1 }; '
          .. 'if ($termRunStatus -eq 0) { java -cp %s %s; $termRunStatus = if ($?) { $LASTEXITCODE } else { 1 } }; '
          .. 'Remove-Item -LiteralPath %s -Recurse -Force -ErrorAction SilentlyContinue; exit $termRunStatus',
        quote(out_dir),
        quote(file),
        quote(out_dir),
        quote(vim.fn.fnamemodify(file, ':t:r')),
        quote(out_dir)
      )
      launch(command, cleanup)
    else
      local command = string.format(
        'javac -d %s %s; term_run_status=$?; ' .. 'if [ "$term_run_status" -eq 0 ]; then java -cp %s %s; term_run_status=$?; fi; ' .. 'rm -rf -- %s; exit "$term_run_status"',
        posix_quote(out_dir),
        posix_quote(file),
        posix_quote(out_dir),
        posix_quote(vim.fn.fnamemodify(file, ':t:r')),
        posix_quote(out_dir)
      )
      launch_posix(command, cleanup)
    end
  elseif ft == 'c' or ft == 'rust' then
    -- 使用唯一临时输出, 不覆盖/删除源码目录中可能已存在的同名可执行文件。
    local compiler = ft == 'c' and 'gcc' or 'rustc'
    local out = vim.fn.tempname() .. (is_win and '.exe' or '')
    local cleanup = { { path = out } }
    local command
    if is_win then
      command = string.format(
        '%s %s -o %s; $termRunStatus = if ($?) { $LASTEXITCODE } else { 1 }; '
          .. 'if ($termRunStatus -eq 0) { & %s; $termRunStatus = $LASTEXITCODE }; '
          .. 'Remove-Item -LiteralPath %s -Force -ErrorAction SilentlyContinue; exit $termRunStatus',
        compiler,
        quote(file),
        quote(out),
        quote(out),
        quote(out)
      )
      launch(command, cleanup)
    else
      command = string.format(
        '%s %s -o %s; term_run_status=$?; ' .. 'if [ "$term_run_status" -eq 0 ]; then %s; term_run_status=$?; fi; ' .. 'rm -f -- %s; exit "$term_run_status"',
        compiler,
        posix_quote(file),
        posix_quote(out),
        posix_quote(out),
        posix_quote(out)
      )
      launch_posix(command, cleanup)
    end
  else
    local label = ft ~= '' and ft or '当前 buffer'
    vim.notify(string.format('未配置 %s 的运行命令', label), vim.log.levels.WARN, { title = 'Terminal' })
  end
end

return M
