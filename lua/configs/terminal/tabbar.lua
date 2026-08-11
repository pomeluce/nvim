local M = {}

local api = vim.api
local state = require('configs.terminal.state')

local tabbar_win
local tabbar_buf
local sync_timer
local tabbar_ns = api.nvim_create_namespace('term_tabbar')

local function stop_sync()
  if sync_timer and not sync_timer:is_closing() then
    sync_timer:stop()
    sync_timer:close()
  end
  sync_timer = nil
end

local function start_sync()
  if sync_timer then return end
  local timer = vim.uv.new_timer()
  if not timer then return end
  sync_timer = timer
  timer:start(
    100,
    100,
    vim.schedule_wrap(function()
      if not tabbar_win or not api.nvim_win_is_valid(tabbar_win) then return stop_sync() end
      for _, t in ipairs(state.tabs) do
        if t.window and api.nvim_win_is_valid(t.window) and t:is_open() then return end
      end
      M.close()
    end)
  )
end

function M.close()
  stop_sync()
  if tabbar_win and api.nvim_win_is_valid(tabbar_win) then api.nvim_win_close(tabbar_win, true) end
  tabbar_win = nil
end

function M.render()
  if not tabbar_buf or not api.nvim_buf_is_valid(tabbar_buf) then return end
  local active_idx = state.active_idx
  if not active_idx or not state.tabs[active_idx] then return end

  api.nvim_buf_clear_namespace(tabbar_buf, tabbar_ns, 0, -1)
  api.nvim_buf_set_lines(tabbar_buf, 0, -1, false, { '' })
  local win_width = (tabbar_win and api.nvim_win_is_valid(tabbar_win)) and api.nvim_win_get_width(tabbar_win) or 100
  local labels = {}
  local label_widths = {}
  for i, t in ipairs(state.tabs) do
    labels[i] = string.format(' %d %s ', i, t.display_name or 'term')
    label_widths[i] = vim.fn.strdisplaywidth(labels[i])
  end

  local function compute_range(budget)
    local left, right = active_idx, active_idx
    local total = label_widths[active_idx]
    while true do
      local added = false
      if right + 1 <= #state.tabs and total + 1 + label_widths[right + 1] <= budget then
        right = right + 1
        total = total + 1 + label_widths[right]
        added = true
      end
      if left - 1 >= 1 and total + 1 + label_widths[left - 1] <= budget then
        left = left - 1
        total = total + 1 + label_widths[left]
        added = true
      end
      if not added then break end
    end
    return left, right
  end

  local left, right = compute_range(win_width)
  local reserve = (left > 1 and 2 or 0) + (right < #state.tabs and 2 or 0)
  if reserve > 0 then
    left, right = compute_range(win_width - reserve)
  end

  local segments = {}
  if left > 1 then table.insert(segments, { '‹ ', 'TermTabSep' }) end
  for i = left, right do
    if i ~= left then table.insert(segments, { '│', 'TermTabSep' }) end
    table.insert(segments, { labels[i], (i == active_idx) and 'TermTabActive' or 'TermTab' })
  end
  if right < #state.tabs then table.insert(segments, { ' ›', 'TermTabSep' }) end

  local content_width = 0
  for _, segment in ipairs(segments) do
    content_width = content_width + vim.fn.strdisplaywidth(segment[1])
  end
  local padding = math.max(0, math.floor((win_width - content_width) / 2))
  if padding > 0 then table.insert(segments, 1, { string.rep(' ', padding), 'TermTabSep' }) end

  api.nvim_buf_set_extmark(tabbar_buf, tabbar_ns, 0, 0, { virt_text = segments, virt_text_pos = 'inline' })
end

function M.open(term)
  local win = term.window
  local pos = api.nvim_win_get_position(win)
  local row, col = pos[1], pos[2]
  local win_opts = {
    relative = 'editor',
    row = math.max(0, row - 2),
    col = col,
    width = api.nvim_win_get_width(win),
    height = 1,
    border = { '╭', '─', '╮', '│', '┤', '─', '├', '│' },
    zindex = 100,
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
  M.render()
  start_sync()
end

function M.is_open() return tabbar_win ~= nil and api.nvim_win_is_valid(tabbar_win) end

return M
