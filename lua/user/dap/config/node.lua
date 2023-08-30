local dap = require('dap')
dap.adapters['pwa-node'] = {
  type = 'server',
  host = 'localhost',
  port = '${port}',
  executable = {
    command = 'node',
    args = { vim.fn.stdpath('data') .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js', '${port}' },
  },
}

require('dap').configurations.javascript = {
  -- debug for vscode-js
  {
    type = 'pwa-node',
    request = 'launch',
    name = 'Debug for JsDebug',
    program = '${file}',
    cwd = '${workspaceFolder}',
  },
}

dap.configurations.typescriptreact = {
  -- debug for vscode-js
  {
    type = 'pwa-node',
    request = 'launch',
    name = 'Debug for TsDebug',
    program = '${file}',
    cwd = '${workspaceFolder}',
  },
}

dap.configurations.vue = {
  -- debug for vscode-js
  {
    type = 'pwa-node',
    request = 'launch',
    name = 'Debug for VueDebug',
    program = '${file}',
    cwd = '${workspaceFolder}',
  },
}
