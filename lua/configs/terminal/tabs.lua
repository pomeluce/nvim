local M = {}

local Terminal = require('toggleterm.terminal').Terminal
local api = vim.api
local float_opts = require('configs.terminal.options').float
local state = require('configs.terminal.state')
local tabbar = require('configs.terminal.tabbar')

local augroup = api.nvim_create_augroup('CustomToggleTerm', { clear = true })
local term_timer
local MAX_ENSURE_ATTEMPTS = 20

local function term_is_open(t)
  if not t or not t.window or not api.nvim_win_is_valid(t.window) then return false end
  return t:is_open()
end

local function term_visible()
  local t = state.active_idx and state.tabs[state.active_idx]
  return term_is_open(t)
end

local function refresh_tabbar()
  if #state.tabs >= 2 then
    local t = state.tabs[state.active_idx]
    if term_is_open(t) then tabbar.open(t) end
  else
    tabbar.close()
  end
end

local function update_titles()
  for _, t in ipairs(state.tabs) do
    if t.window and api.nvim_win_is_valid(t.window) then
      local ok, cfg = pcall(api.nvim_win_get_config, t.window)
      if ok and cfg then
        cfg.title = t.display_name
        pcall(api.nvim_win_set_config, t.window, cfg)
      end
    end
  end
end

local function renumber_tabs()
  for i, t in ipairs(state.tabs) do
    if not t.custom then t.display_name = (#state.tabs == 1) and 'Term' or string.format('Term%d', i) end
  end
  update_titles()
end

local function ensure_terminal(target)
  local expected = state.tabs[target]
  if term_timer and not term_timer:is_closing() then
    term_timer:stop()
    term_timer:close()
  end
  term_timer = nil
  local timer = vim.uv.new_timer()
  if not timer then
    vim.schedule(function()
      if state.tabs[state.active_idx] == expected and term_is_open(expected) then
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
      if attempts > MAX_ENSURE_ATTEMPTS or state.tabs[state.active_idx] ~= expected or not term_is_open(expected) then return finish() end
      if api.nvim_get_current_win() ~= expected.window then api.nvim_set_current_win(expected.window) end
      if vim.fn.mode() ~= 't' then
        vim.cmd('startinsert!')
      else
        return finish()
      end
    end)
  )
end

local function on_tab_exit(t)
  local was_visible = term_visible()
  local was_active = state.active_idx ~= nil and state.tabs[state.active_idx] == t
  vim.schedule(function()
    local idx
    for i, candidate in ipairs(state.tabs) do
      if candidate == t then
        idx = i
        break
      end
    end
    if not idx then return end
    if t.shutdown then pcall(t.shutdown, t) end
    table.remove(state.tabs, idx)
    if #state.tabs == 0 then
      state.active_idx = nil
      tabbar.close()
      return
    end
    if state.active_idx then
      if idx < state.active_idx then
        state.active_idx = state.active_idx - 1
      elseif idx == state.active_idx then
        state.active_idx = math.min(idx, #state.tabs)
      end
    else
      state.active_idx = 1
    end
    renumber_tabs()
    if was_visible and was_active then
      M.show(state.active_idx)
      ensure_terminal(state.active_idx)
    elseif was_visible then
      refresh_tabbar()
    else
      tabbar.close()
    end
  end)
end

local function make_term()
  return Terminal:new({
    dir = vim.fn.getcwd(),
    hidden = true,
    close_on_exit = true,
    float_opts = float_opts,
    on_open = function() vim.cmd('startinsert!') end,
    on_exit = on_tab_exit,
  })
end

function M.show(idx)
  if not state.tabs[idx] then return end
  state.active_idx = idx
  local expected = state.tabs[idx]
  for i = #state.tabs, 1, -1 do
    if i ~= idx and state.tabs[i]:is_open() then state.tabs[i]:close() end
  end
  if not expected:is_open() then expected:open() end
  refresh_tabbar()
  vim.schedule(function()
    if state.tabs[state.active_idx] == expected and term_is_open(expected) then
      api.nvim_set_current_win(expected.window)
      vim.cmd('startinsert!')
    end
  end)
end

function M.toggle_default()
  if #state.tabs == 0 then
    M.new_tab()
  elseif state.tabs[state.active_idx] and state.tabs[state.active_idx]:is_open() then
    state.tabs[state.active_idx]:close()
    tabbar.close()
  else
    M.show(state.active_idx or 1)
  end
end

function M.new_tab()
  local t = make_term()
  t.custom = false
  table.insert(state.tabs, t)
  renumber_tabs()
  M.show(#state.tabs)
end

function M.close_tab()
  if not state.active_idx or not state.tabs[state.active_idx] then return end
  local idx = state.active_idx
  local t = state.tabs[idx]
  if t:is_open() then t:close() end
  if t.shutdown then pcall(t.shutdown, t) end
  table.remove(state.tabs, idx)
  if #state.tabs == 0 then
    state.active_idx = nil
    tabbar.close()
    return
  end
  renumber_tabs()
  state.active_idx = math.min(idx, #state.tabs)
  M.show(state.active_idx)
  ensure_terminal(state.active_idx)
end

function M.next_tab()
  if #state.tabs >= 2 then M.show((state.active_idx or 1) % #state.tabs + 1) end
end

function M.prev_tab()
  if #state.tabs >= 2 then M.show(((state.active_idx or 1) - 2) % #state.tabs + 1) end
end

function M.goto_tab(n)
  if state.tabs[n] then M.show(n) end
end

function M.select_tab()
  if #state.tabs == 0 then return end
  vim.ui.select(state.tabs, {
    prompt = 'Terminal tab:',
    format_item = function(t) return t.display_name or 'Term' end,
  }, function(choice)
    if not choice then return end
    for i, t in ipairs(state.tabs) do
      if t == choice then
        M.show(i)
        return
      end
    end
  end)
end

function M.rename_tab(name, on_done)
  if not state.active_idx or not state.tabs[state.active_idx] then
    if on_done then on_done() end
    return
  end
  local target = state.tabs[state.active_idx]
  local function apply(new_name)
    local target_idx
    for i, t in ipairs(state.tabs) do
      if t == target then
        target_idx = i
        break
      end
    end
    if target_idx and new_name and new_name ~= '' then
      target.display_name = new_name
      target.custom = true
      update_titles()
      refresh_tabbar()
      vim.schedule(function()
        if state.tabs[state.active_idx] == target and target.window and api.nvim_win_is_valid(target.window) then
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

local PREFIX_HELP = 'Term  n:new  w/x:close  h/l:prev·next  r:rename  s:select  1-9:goto  q/<C-t>:hide'

local prefix_actions = {
  n = M.new_tab,
  w = M.close_tab,
  x = M.close_tab,
  h = M.prev_tab,
  l = M.next_tab,
  r = M.rename_tab,
  s = M.select_tab,
  q = M.toggle_default,
}

function M.toggle_or_prefix()
  local active = state.active_idx and state.tabs[state.active_idx]
  local active_win = active and active.window
  if not active or not active_win or not term_is_open(active) then
    M.toggle_default()
    return
  end
  if api.nvim_get_current_win() ~= active_win then
    api.nvim_set_current_win(active_win)
    vim.cmd('startinsert!')
    return
  end

  api.nvim_echo({ { PREFIX_HELP, 'ModeMsg' } }, false, {})
  local ok, key = pcall(vim.fn.getcharstr)
  api.nvim_echo({ { '' } }, false, {})
  if not ok or key == '' then return end

  local translated = vim.fn.keytrans(key)
  if translated == '<Esc>' then return end
  if translated == '<C-T>' then
    M.toggle_default()
  elseif key:match('^[1-9]$') then
    M.goto_tab(tonumber(key))
  elseif prefix_actions[key] then
    prefix_actions[key]()
  end
end

api.nvim_create_autocmd('VimResized', {
  group = augroup,
  callback = function()
    vim.schedule(function()
      if not tabbar.is_open() then return end
      local t = state.active_idx and state.tabs[state.active_idx]
      if term_is_open(t) then tabbar.open(t) end
    end)
  end,
})

local function schedule_visibility_sync()
  vim.schedule(function()
    if not term_visible() then tabbar.close() end
  end)
end

api.nvim_create_autocmd('WinClosed', {
  group = augroup,
  callback = function(args)
    local win = tonumber(args.match)
    if not win then return end
    for _, t in ipairs(state.tabs) do
      if t.window == win then
        schedule_visibility_sync()
        return
      end
    end
  end,
})

api.nvim_create_autocmd('BufWinLeave', {
  group = augroup,
  callback = function(args)
    for _, t in ipairs(state.tabs) do
      if t.bufnr == args.buf then
        schedule_visibility_sync()
        return
      end
    end
  end,
})

return M
