package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path
vim.opt.rtp:prepend(vim.fn.getcwd())
local Launch = require('configs.java.launch')

local cases = {
  { [[start --name "demo service" '' "" foo\ bar]], { 'start', '--name', 'demo service', '', '', 'foo bar' } },
  { [['C:\project\demo' "say \"hello\"" init]], { [[C:\project\demo]], 'say "hello"', 'init' } },
  { [['$(touch should-not-exist)' '$HOME' ';' '*']], { '$(touch should-not-exist)', '$HOME', ';', '*' } },
}
for _, case in ipairs(cases) do
  assert(vim.deep_equal(Launch.split_args(case[1]), case[2]))
  assert(vim.deep_equal(Launch.split_args(Launch.format_args(case[2])), case[2]), 'input prefill must preserve argv')
end
for _, invalid in ipairs({ [["unfinished]], [['unfinished]], [[trailing\]], { 'start', 1 }, { unexpected = 'key' } }) do
  assert(not pcall(Launch.split_args, invalid), 'invalid arguments must fail before launch')
end
local supplied = { 'start', '' }
local parsed = Launch.split_args(supplied)
parsed[1] = 'stop'
assert(supplied[1] == 'start', 'arguments must not alias caller data')

local root = vim.fn.tempname()
vim.fn.mkdir(root .. '/.nvim', 'p')
local function defaults(args) vim.fn.writefile({ "return { mainClass = { ['example.App'] = { args = " .. vim.inspect(args) .. ' } } }' }, root .. '/.nvim/java-launch.lua') end
defaults({ 'start', '--name', 'demo service' })
local launch = Launch.new(root)
assert(vim.deep_equal(launch:arguments({ mainClass = 'example.App' }), { 'start', '--name', 'demo service' }))
assert(vim.deep_equal(launch:arguments({ mainClass = 'example.App', args = {} }), {}), 'empty override must clear defaults')
assert(vim.deep_equal(launch:arguments({ mainClass = 'example.App', args = 'stop' }), { 'stop' }))
defaults({ 'init' })
assert(vim.deep_equal(launch:arguments({ mainClass = 'example.App' }), { 'init' }), 'defaults must reload')
vim.fn.delete(root, 'rf')
print('java launch argument tests passed')
