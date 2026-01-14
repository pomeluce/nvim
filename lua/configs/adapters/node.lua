local dap = require('dap')

dap.adapters['pwa-node'] = { type = 'server', host = 'localhost', port = '${port}', executable = { command = 'js-debug', args = { '${port}' } } }
dap.adapters.firefox = { type = 'executable', command = 'node', args = { os.getenv('VSC_FIREFOX_DEBUG') .. '/dist/adapter.bundle.js' } }

dap.configurations.javascript = dap.configurations.javascript or {}

local function input_url(default) return vim.fn.input('Dev server URL: ', default or 'http://localhost:', 'file') end

vim.list_extend(dap.configurations.javascript, {
  { name = 'Node: Debug current file', type = 'pwa-node', request = 'launch', program = '${file}', cwd = '${workspaceFolder}' },
  {
    name = 'Firefox: Debug Web page',
    type = 'firefox',
    request = 'launch',
    reAttach = true,
    url = function() return vim.g.node_debug_url or input_url('http://localhost:') end,
    webRoot = '${workspaceFolder}',
    firefoxExecutable = vim.fn.exepath('firefox'),
  },
})

dap.configurations.javascriptreact = dap.configurations.javascript
dap.configurations.typescript = dap.configurations.javascript
dap.configurations.typescriptreact = dap.configurations.javascript
dap.configurations.vue = dap.configurations.javascript
