package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

local mains = {
  { mainClass = 'example.AuthApplication', projectName = 'auth' },
  { mainClass = 'example.BootApplication', projectName = 'boot' },
  { mainClass = 'example.GatewayApplication', projectName = 'gateway' },
  { mainClass = 'example.JobApplication', projectName = 'job' },
}

package.loaded['jdtls.dap'] = {
  setup_dap_main_class_configs = function() error('runner must not use eager nvim-jdtls DAP discovery') end,
}

local client = {
  server_capabilities = { executeCommandProvider = { commands = {} } },
  request = function(_, method, params, callback)
    assert(method == 'workspace/executeCommand')
    assert(params.command == 'vscode.java.resolveMainClass')
    callback(nil, vim.deepcopy(mains))
    return true, 1
  end,
}

local original_get_clients = vim.lsp.get_clients
local original_select = vim.ui.select
vim.lsp.get_clients = function() return { client } end

local selected_items
vim.ui.select = function(items) selected_items = items end

local runner = require('configs.java.runner').new('/workspace', {}, true)
runner:start()
assert(vim.wait(1000, function() return selected_items ~= nil end), 'Main selector was not opened')

vim.lsp.get_clients = original_get_clients
vim.ui.select = original_select

assert(#selected_items == #mains, ('expected all %d Main targets, got %d'):format(#mains, #selected_items))

print('java runner tests passed')
