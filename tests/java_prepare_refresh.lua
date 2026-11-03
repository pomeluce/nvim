package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

local pending
package.loaded['configs.java.workspace'] = {
  new = function()
    return { sync = function(_, _, _, callback) pending = callback end }
  end,
}
local commands = {}
local client = {
  request = function(_, _, params, callback)
    commands[#commands + 1] = params.command
    callback(nil, { { mainClass = 'example.Main', projectName = 'app' } })
    return true, #commands
  end,
}
local original_clients = vim.lsp.get_clients
vim.lsp.get_clients = function() return { client } end
local prepare = require('configs.java.prepare').new('/workspace', {})
local cancelled
prepare:discover(0, function(err) cancelled = err end)
assert(#commands == 0, 'Main discovery must wait for workspace refresh')
assert(prepare:cancel())
pending()
assert(cancelled and cancelled.kind == 'cancelled')
assert(#commands == 0, 'finishing a cancelled refresh must not resume launch requests')

local mains
prepare:discover(0, function(err, result)
  assert(not err)
  mains = result
end)
pending()
assert(vim.wait(500, function() return mains ~= nil end))
assert(#mains == 1 and commands[1] == 'vscode.java.resolveMainClass')

local failure
prepare:prepare(mains[1], 0, function(err) failure = err end)
assert(#commands == 1, 'explicit Main launches must also wait for workspace refresh')
pending({ kind = 'refresh', message = 'Import failed' })
assert(failure and failure.kind == 'refresh')
assert(#commands == 1, 'failed refreshes must not build or resolve stale classpaths')
vim.lsp.get_clients = original_clients
print('java preparation refresh tests passed')
