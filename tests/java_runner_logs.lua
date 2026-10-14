package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

vim.o.columns = 220
vim.o.lines = 30
package.loaded.jdtls = setmetatable({}, {
  __index = function()
    return function() end
  end,
})

local runner = require('configs.java.runner').new('/tmp', {}, false)
require('configs.java.actions').attach(vim.api.nvim_get_current_buf(), { runner = runner })

local function resize_handlers() return #vim.api.nvim_get_autocmds({ event = 'WinResized' }) + #vim.api.nvim_get_autocmds({ event = 'VimResized' }) end
local initial_resize_handlers = resize_handlers()

local function add_run(main_class, project_name)
  local key = tostring(#runner.run_order + 1)
  local run = {
    buf = vim.api.nvim_create_buf(false, true),
    main_class = main_class,
    project_name = project_name or '',
  }
  runner.runs[key] = run
  runner.run_order[#runner.run_order + 1] = key
  runner.log_buffer_attach(run.buf)
  return run
end

for i = 1, 5 do
  runner.current = add_run(('example.Application%d'):format(i))
end

local function resize(width)
  if vim.api.nvim_win_get_width(runner.log_win) == vim.o.columns then vim.api.nvim_win_call(runner.log_win, function() vim.cmd('vsplit') end) end
  vim.api.nvim_win_set_width(runner.log_win, width)
  vim.api.nvim_exec_autocmds('WinResized', {})
end

local function rendered()
  local width = vim.api.nvim_win_get_width(runner.log_win)
  local result = vim.api.nvim_eval_statusline(vim.wo[runner.log_win].winbar, {
    winid = runner.log_win,
    use_winbar = true,
    maxwidth = width,
    highlights = true,
  })
  assert(result.width <= width, 'winbar exceeds the log window width')
  assert(not result.str:find('<', 1, true), 'Neovim truncated the winbar')
  local active
  for i, highlight in ipairs(result.highlights) do
    if vim.tbl_contains(highlight.groups, 'TabLineSel') then
      active = result.str:sub(highlight.start + 1, result.highlights[i + 1] and result.highlights[i + 1].start or #result.str)
      break
    end
  end
  assert(active and active:find('%S'), 'current log tab has no visible highlight')
  return result.str, active
end

local function expect_current(index)
  assert(runner.current == runner.runs[tostring(index)], 'current Main did not switch')
  assert(vim.api.nvim_win_get_buf(runner.log_win) == runner.current.buf, 'log buffer did not switch')
  local text, active = rendered()
  assert(active:find('Application' .. index, 1, true), 'current Main tab is hidden: ' .. text)
  return text
end

vim.cmd('JavaToggleLogs')
resize(60)
expect_current(5)
for index = 4, 1, -1 do
  vim.cmd('JavaPreviousLog')
  expect_current(index)
end
assert(expect_current(1):find('›', 1, true), 'missing right overflow indicator')
vim.cmd('JavaPreviousLog')
assert(expect_current(5):find('‹', 1, true), 'missing left overflow indicator')
vim.cmd('JavaNextLog')
expect_current(1)
for index = 2, 5 do
  vim.cmd('JavaNextLog')
  expect_current(index)
end

vim.cmd('JavaToggleLogs')
vim.cmd('JavaToggleLogs')
expect_current(5)

resize(24)
expect_current(5)
vim.cmd('JavaPreviousLog')
vim.cmd('JavaPreviousLog')
local middle = expect_current(3)
assert(middle:find('‹', 1, true) and middle:find('›', 1, true), 'middle tabs must show overflow on both sides')
vim.cmd('JavaNextLog')
vim.cmd('JavaNextLog')
vim.api.nvim_win_set_width(runner.log_win, 180)
vim.api.nvim_exec_autocmds('VimResized', {})
local text = expect_current(5)
for i = 1, 5 do
  assert(text:find('Application' .. i, 1, true), 'tabs must reappear when the window grows: ' .. vim.api.nvim_win_get_width(runner.log_win) .. ' columns: ' .. text)
end
assert(not text:find('‹', 1, true) and not text:find('›', 1, true), 'overflow indicators remain when all tabs fit')

local long = add_run('example.非常长的JavaApplication名称用于测试窄窗口', '')
runner.current = long
runner:show(long.buf)
resize(24)
local _, active = rendered()
assert(active:find('…', 1, true), 'long Main names must be shortened')
assert(active:find('非常', 1, true), 'truncation must preserve a recognizable class name')
resize(8)
rendered()
resize(1)
rendered()

resize(50)
local percent = add_run('example.Progress%Application', 'project%name')
runner.current = percent
runner:show(percent.buf)
local _, percent_active = rendered()
assert(percent_active:find('Progress%Application', 1, true), 'literal percent in a Main name was not escaped')

local duplicate = add_run('other.Progress%Application', 'other%project')
runner.current = duplicate
runner:show(duplicate.buf)
local _, duplicate_active = rendered()
assert(duplicate_active:find('other%project/Progress%Application', 1, true), 'duplicate class names must retain the project label')

vim.api.nvim_buf_delete(percent.buf, { force = true })
vim.api.nvim_exec_autocmds('WinResized', {})
local _, remaining_active = rendered()
assert(remaining_active:find('Progress%Application', 1, true), 'invalid log buffers must not hide the current tab')
assert(not remaining_active:find('other%project', 1, true), 'deleted duplicates must stop affecting labels')

vim.cmd('JavaToggleLogs')
assert(resize_handlers() == initial_resize_handlers, 'closing the log window must remove its resize handlers')
vim.api.nvim_exec_autocmds('WinResized', {})
vim.cmd('JavaToggleLogs')
rendered()

vim.o.ambiwidth = 'double'
for _, width in ipairs({ 1, 8, 12, 24, 50 }) do
  resize(width)
  rendered()
end

print('java runner log tests passed')
