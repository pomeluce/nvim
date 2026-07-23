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

local FLOAT_OPTS = { width = 120, height = 36, border = 'rounded' }
-- ensure_terminal 轮询上限(次), 每 10ms 一次 → 最多约 200ms
local MAX_ENSURE_ATTEMPTS = 20

---------------------------------------------------------------------------
-- 命名单实例终端(给 RUN 等用)
---------------------------------------------------------------------------
function M.floaterm(name, cmd, close, opts)
  if terminals[name] and cmd ~= '' and terminals[name].cmd ~= cmd then
    if terminals[name]:is_open() then terminals[name]:toggle() end
    terminals[name] = nil
  end
  if not terminals[name] then
    terminals[name] = Terminal:new({
      cmd = cmd ~= '' and cmd or nil,
      display_name = name,
      dir = 'git_dir',
      close_on_exit = close or false,
      float_opts = opts,
      hidden = true,
      on_open = function(_) vim.cmd('startinsert!') end,
    })
  end

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
        if t.window and api.nvim_win_is_valid(t.window) then return end
      end
      M._close_tabbar()
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
  for i = 1, #tabs do
    labels[i] = string.format(' %d %s ', i, tabs[i].display_name or 'term')
  end
  -- 以 active 为中心向两侧扩展, 受 tab 栏宽度约束; 为溢出标记 ‹ › 预留空间
  local function compute_range(budget)
    local l, r = active_idx, active_idx
    local total = #labels[active_idx]
    while true do
      local added = false
      if r + 1 <= #tabs and total + 1 + #labels[r + 1] <= budget then
        r = r + 1
        total = total + 1 + #labels[r]
        added = true
      end
      if l - 1 >= 1 and total + 1 + #labels[l - 1] <= budget then
        l = l - 1
        total = total + 1 + #labels[l]
        added = true
      end
      if not added then break end
    end
    return l, r
  end
  local left, right = compute_range(win_width)
  local reserve = (left > 1 and 2 or 0) + (right < #tabs and 2 or 0)
  if reserve > 0 then
    left, right = compute_range(win_width - reserve)
  end
  local segments = {}
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
  local cfg = api.nvim_win_get_config(term.window)
  local function num(v)
    if type(v) == 'table' then return v[1] or 0 end
    return v or 0
  end
  local row, col, width = num(cfg.row), num(cfg.col), cfg.width or 100
  local win_opts = {
    relative = 'editor',
    row = math.max(0, row - 3), -- 紧贴 term 窗口 border 上方, 留 1 行间隙
    col = col,
    width = width,
    height = 1,
    border = 'rounded',
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

-- 依据当前 tab 数量决定 tab 栏开关: >=2 显示并刷新, 否则关闭
local function refresh_tabbar()
  if #tabs >= 2 then
    local t = tabs[active_idx]
    if t and t.window and api.nvim_win_is_valid(t.window) then M._open_tabbar(t) end
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
  -- 停止上一个轮询 timer, 避免连续操作时多个 timer 并发互相抢焦点
  if term_timer and not term_timer:is_closing() then
    term_timer:stop()
    term_timer:close()
  end
  term_timer = nil
  local timer = vim.uv.new_timer()
  if not timer then
    vim.schedule(function()
      local cur = tabs[target]
      if cur and cur.window and api.nvim_win_is_valid(cur.window) then
        api.nvim_set_current_win(cur.window)
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
      local cur = tabs[target]
      local function finish()
        timer:stop()
        if not timer:is_closing() then timer:close() end
        if term_timer == timer then term_timer = nil end
      end
      if attempts > MAX_ENSURE_ATTEMPTS or not cur or not cur.window or not api.nvim_win_is_valid(cur.window) then return finish() end
      if api.nvim_get_current_win() ~= cur.window then api.nvim_set_current_win(cur.window) end
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
    M.show(active_idx)
    refresh_tabbar()
    ensure_terminal(active_idx)
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
  -- 先关闭其他 tab(其 close 会 stopinsert/改焦点), 再 open active, 避免刚 startinsert 就被打断
  for i = #tabs, 1, -1 do
    if i ~= idx and tabs[i]:is_open() then tabs[i]:close() end
  end
  if not tabs[idx]:is_open() then tabs[idx]:open() end
  refresh_tabbar()
  -- 切换后确保焦点回到 active tab 并进入 terminal 模式(异步, 等所有窗口操作完成)
  vim.schedule(function()
    local t = tabs[idx]
    if t and t.window and api.nvim_win_is_valid(t.window) then
      api.nvim_set_current_win(t.window)
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
function M.rename_tab(name)
  if not active_idx or not tabs[active_idx] then return end
  local function apply(n)
    if not n or n == '' then return end
    tabs[active_idx].display_name = n
    tabs[active_idx].custom = true
    update_titles()
    refresh_tabbar()
    -- 改名后回到终端 insert
    vim.schedule(function()
      local t = tabs[active_idx]
      if t and t.window and api.nvim_win_is_valid(t.window) then
        api.nvim_set_current_win(t.window)
        vim.cmd('startinsert!')
      end
    end)
  end
  if name and name ~= '' then
    apply(name)
  else
    vim.ui.input({ prompt = 'Terminal name: ', default = tabs[active_idx].display_name or '' }, apply)
  end
end

---------------------------------------------------------------------------
-- 运行当前文件(RUN 终端)
---------------------------------------------------------------------------
function M.runFile()
  vim.cmd('w')
  local ft = vim.api.nvim_eval('&ft')
  local file = vim.fn.expand('%:p')
  local file_root = vim.fn.expand('%:p:r')

  local run_cmd = vim.list_extend({
    javascript = 'node',
    typescript = 'ts-node',
    html = 'firefox',
    python = 'python3',
    go = 'go run',
    sh = 'bash',
    lua = 'lua',
  }, require('settings').file.run_cmd)

  if run_cmd[ft] then
    M.floaterm('RUN', string.format('%s %s', run_cmd[ft], file))
  elseif ft == 'markdown' then
    vim.cmd('MarkdownPreview')
  elseif ft == 'java' then
    M.floaterm('RUN', string.format('javac %s && java %s', file, file_root))
  elseif ft == 'c' then
    M.floaterm('RUN', string.format('gcc %s -o %s && ./%s && rm %s', file, file_root, file_root, file_root))
  elseif ft == 'rust' then
    M.floaterm('RUN', string.format('rustc %s -o %s && ./%s && rm %s', file, file_root, file_root, file_root))
  end
end

return M
