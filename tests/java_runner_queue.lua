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
runner:stop()
assert(cancel_count == 1, 'JavaStopMain must cancel launch preparation')
pending[3]({ kind = 'cancelled' })
vim.wait(50)
assert(#prepare_calls == 3, 'JavaStopMain must clear queued launch preparations')
assert(#launched == 2, 'cancelled preparation must not launch a process')

print('java runner queue tests passed')
