package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path
vim.opt.rtp:prepend(vim.fn.getcwd())
local calls, pending, discoveries, selections, notifications = {}, {}, {}, {}, {}
local cancelled = 0
package.loaded['configs.java.prepare'] = {
  new = function()
    return {
      discover = function(_, _, callback) discoveries[#discoveries + 1] = callback end,
      prepare = function(_, config, bufnr, callback)
        calls[#calls + 1] = { config = config, bufnr = bufnr }
        pending[#pending + 1] = callback
      end,
      cancel = function() cancelled = cancelled + 1 end,
    }
  end,
}
package.loaded['configs.java.picker'] = {
  select = function(items, options, callback) selections[#selections + 1] = { items = items, options = options, callback = callback } end,
}
vim.notify = function(message) notifications[#notifications + 1] = message end
local root = vim.fn.tempname()
vim.fn.mkdir(root .. '/.nvim', 'p')
vim.fn.writefile({ "return { mainClass = { ['example.A'] = { args = {'start'} }, ['example.B'] = { args = {'queued-default'} } } }" }, root .. '/.nvim/java-launch.lua')
local runner = require('configs.java.runner').new(root, {}, true)
local launched = {}
function runner:run(config)
  launched[#launched + 1] = config
  return 'started'
end
local a, b, c = { mainClass = 'example.A', projectName = 'a' }, { mainClass = 'example.B', projectName = 'b' }, { mainClass = 'example.C', projectName = 'c' }
local function wait_calls(count)
  assert(vim.wait(1000, function() return #calls == count end))
end

runner:start()
discoveries[1](nil, { a, b, c })
assert(selections[1].options.multiple)
selections[1].callback({ a, b, c })
wait_calls(1)
assert(vim.deep_equal(calls[1].config.args, { 'start' }))
assert(#runner.launch_queue == 2)
-- Changing a default while waiting must not change a queued instance's identity.
vim.fn.writefile({ "return { mainClass = { ['example.A'] = { args = {'stop'} } } }" }, root .. '/.nvim/java-launch.lua')
pending[1]({ kind = 'build', message = 'fixture build failure' })
wait_calls(2)
assert(calls[2].config.mainClass == b.mainClass, 'one failed service must not abort the rest')
assert(vim.deep_equal(calls[2].config.args, { 'queued-default' }), 'queued arguments must retain their confirmed values')
pending[2](nil, calls[2].config)
wait_calls(3)
pending[3](nil, calls[3].config)
assert(#launched == 2)
assert(notifications[#notifications]:find('2 started, 0 skipped, 1 failed', 1, true))

-- Cancel one queued target without cancelling active preparation or another target.
runner:launch(a, 10)
runner:launch(b, 20)
runner:launch(c, 30)
wait_calls(4)
local candidates = runner:stop_candidates()
runner:stop_selected({ candidates[2] })
assert(cancelled == 0 and #runner.launch_queue == 1)
pending[4](nil, calls[4].config)
wait_calls(5)
assert(calls[5].config.mainClass == c.mainClass)
pending[5](nil, calls[5].config)

-- Cancel active preparation, reject its stale completion, then continue the queue.
runner:launch(a, 10)
runner:launch(b, 20)
wait_calls(6)
runner:stop_selected({ runner:stop_candidates()[1] })
assert(cancelled == 1)
pending[6](nil, calls[6].config)
wait_calls(7)
assert(calls[7].config.mainClass == b.mainClass)
assert(#launched == 4, 'cancelled active target must not launch')
pending[7](nil, calls[7].config)

-- Temporary arguments are prefilled, can clear defaults, and are not persisted.
local input_options, input_callback
vim.ui.input = function(options, callback)
  input_options, input_callback = options, callback
end
runner:start(true)
discoveries[2](nil, { a })
assert(not selections[2].options.multiple)
selections[2].callback({ a })
assert(input_options.default == 'stop')
input_callback('')
wait_calls(8)
assert(vim.deep_equal(calls[8].config.args, {}))
pending[8](nil, calls[8].config)
assert(require('configs.java.launch').new(root):arguments(a)[1] == 'stop')
runner:start(true)
discoveries[3](nil, { a })
selections[3].callback({ a })
input_callback(nil)
vim.wait(20)
assert(#calls == 8, 'cancelled argument entry must not build or launch')

-- StopAll cancels discovery and ignores a selector callback arriving afterwards.
runner:start()
discoveries[4](nil, { a, b })
runner:stop_all()
selections[4].callback({ a, b })
vim.wait(20)
assert(#calls == 8 and cancelled == 2)

-- A selected discovery request may become a batch before the stop picker confirms.
runner:start()
local discovery_candidate = runner:stop_candidates()[1]
discoveries[5](nil, { a, b })
selections[5].callback({ a, b })
wait_calls(9)
runner:stop_selected({ discovery_candidate })
assert(cancelled == 3 and #runner.launch_queue == 0)
local launched_before = #launched
pending[9](nil, calls[9].config)
vim.wait(20)
assert(#launched == launched_before and #calls == 9, 'stopping a discovery request must cancel its resulting batch')

local debug_config
package.loaded.dap = { run = function(config) debug_config = config end }
runner:debug(true)
discoveries[6](nil, { a })
selections[6].callback({ a })
input_callback([[init --name "debug service" ""]])
wait_calls(10)
pending[10](nil, calls[10].config)
assert(vim.deep_equal(debug_config.args, { 'init', '--name', 'debug service', '' }), 'Debug must receive the same parsed program arguments as Run')
assert(require('configs.java.launch').new(root):arguments(a)[1] == 'stop', 'temporary Debug args must not change defaults')
vim.fn.delete(root, 'rf')
print('java runner batch tests passed')
