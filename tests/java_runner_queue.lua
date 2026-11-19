package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

local prepare_calls = {}
local pending = {}
local cancel_count = 0

package.loaded['configs.java.prepare'] = {
  new = function()
    return {
      discover = function() error('explicit launch targets must not be rediscovered') end,
      prepare = function(_, config, bufnr, callback)
        prepare_calls[#prepare_calls + 1] = { config = config, bufnr = bufnr }
        pending[#pending + 1] = callback
      end,
      cancel = function()
        cancel_count = cancel_count + 1
        return true
      end,
    }
  end,
}

local runner = require('configs.java.runner').new('/workspace', {}, true)
local launched = {}
function runner:run(config) launched[#launched + 1] = { mode = 'run', config = config } end
function runner:debug_config(config) launched[#launched + 1] = { mode = 'debug', config = config } end

local first = { mainClass = 'example.FirstApplication', projectName = 'first' }
local second = { mainClass = 'example.SecondApplication', projectName = 'second' }
runner:launch(first, 11)
runner:enqueue('debug', 22, second)

assert(#prepare_calls == 1, 'only one launch may be prepared at a time')
assert(prepare_calls[1].bufnr == 11)
pending[1](nil, vim.tbl_extend('force', first, { javaExec = '/jdk/bin/java', classPaths = {}, modulePaths = {} }))
assert(vim.wait(1000, function() return #prepare_calls == 2 end), 'queued launch preparation did not start')
assert(prepare_calls[2].bufnr == 22)
assert(#launched == 1 and launched[1].mode == 'run')

pending[2](nil, vim.tbl_extend('force', second, { javaExec = '/jdk/bin/java', classPaths = {}, modulePaths = {} }))
assert(vim.wait(1000, function() return #launched == 2 end), 'queued Debug launch did not start')
assert(launched[2].mode == 'debug')

runner:launch(first, 33)
runner:enqueue('debug', 44, second)
assert(vim.wait(1000, function() return #prepare_calls == 3 end), 'cancellable launch preparation did not start')
runner:stop_all()
assert(cancel_count == 1, 'JavaStopAll must cancel Run preparation')
pending[3]({ kind = 'cancelled' })
assert(vim.wait(1000, function() return #prepare_calls == 4 end), 'JavaStopAll must preserve queued Debug launches')
assert(#launched == 2, 'cancelled Run preparation must not launch a process')
pending[4](nil, second)
assert(#launched == 3 and launched[3].mode == 'debug')

runner:enqueue('debug', 55, first)
runner:launch(second, 66)
assert(vim.wait(1000, function() return #prepare_calls == 5 end))
runner:stop_all()
assert(cancel_count == 1 and #runner.launch_queue == 0, 'StopAll must not cancel active Debug preparation')
pending[5](nil, first)
assert(#launched == 4 and launched[4].mode == 'debug')

print('java runner queue tests passed')
