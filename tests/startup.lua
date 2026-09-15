package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

local command_index = 0

local function resolve(argv)
  package.loaded['core.startup'] = nil
  local startup = require('core.startup')
  command_index = command_index + 1
  local command = 'TestTool' .. command_index
  startup.register_tool_command(command, function() end)

  local callback_count = 0
  startup.on_resolved(function() callback_count = callback_count + 1 end)
  startup.resolve(vim.tbl_map(function(arg) return (arg:gsub('{command}', command)) end, argv))
  assert(callback_count == 1, 'startup callbacks must run exactly once')
  startup.resolve(argv)
  assert(callback_count == 1, 'startup resolution must be idempotent')

  vim.api.nvim_del_user_command(command)
  return startup
end

assert(resolve({ 'nvim', '+{command}' }):is_tool_launch())
assert(resolve({ 'nvim', '-c', '{command}' }):is_tool_launch())
assert(resolve({ 'nvim', '-c{command}' }):is_tool_launch())
assert(resolve({ 'nvim', 'query.sql', '+{command}', '+SomeOtherCommand' }):is_tool_launch())
assert(not resolve({ 'nvim' }):is_tool_launch())
assert(not resolve({ 'nvim', '--cmd', '{command}' }):is_tool_launch())
assert(not resolve({ 'nvim', '-c', 'silent {command}' }):is_tool_launch())

package.loaded['core.startup'] = nil
local multiple_startup = require('core.startup')
multiple_startup.register_tool_command('FirstTool', function() end)
multiple_startup.register_tool_command('SecondTool', function() end)
multiple_startup.resolve({ 'nvim', '+SecondTool' })
assert(multiple_startup.is_tool_launch(), 'any registered tool command must activate tool launch')
vim.api.nvim_del_user_command('FirstTool')
vim.api.nvim_del_user_command('SecondTool')

package.loaded['core.startup'] = nil
local runtime_startup = require('core.startup')
local runtime_count = 0
runtime_startup.register_tool_command('RuntimeTool', function() runtime_count = runtime_count + 1 end)
runtime_startup.resolve({ 'nvim' })
vim.cmd('RuntimeTool')
assert(runtime_count == 1, 'tool command must remain available during a normal editor session')
assert(not runtime_startup.is_tool_launch(), 'runtime command execution must not change startup state')
vim.api.nvim_del_user_command('RuntimeTool')

local startup = resolve({ 'nvim' })
local ok, err = pcall(startup.register_tool_command, 'LateTool', function() end)
assert(not ok and tostring(err):find('after startup has been resolved', 1, true))
assert(vim.fn.exists(':LateTool') == 0, 'late registration must not create a partial command')

print('startup tests passed')
