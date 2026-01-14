local dap = require('dap')

dap.adapters.gdb = { type = 'executable', command = 'gdb', args = { '--interpreter=dap', '--eval-command', 'set print pretty on' } }
dap.adapters.cppdbg = {
  id = 'cppdbg',
  type = 'executable',
  command = vim.fn.getenv('VSC_CPPTOOLS_DEBUG') .. '/debugAdapters/bin/OpenDebugAD7',
  options = { detached = false },
}
dap.adapters.codelldb = { type = 'executable', command = 'codelldb' }

dap.configurations.c = dap.configurations.c or {}

vim.list_extend(dap.configurations.c, {
  {
    name = 'Launch (codelldb)',
    type = 'codelldb',
    request = 'launch',
    program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file') end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
  {
    name = 'Launch (gdb)',
    type = 'cppdbg',
    MIMode = 'gdb',
    request = 'launch',
    miDebuggerPath = 'gdb',
    program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file') end,
    cwd = '${workspaceFolder}',
    setupCommands = { { description = 'Enable pretty-printing for gdb', ignoreFailures = true, text = '-enable-pretty-printing' } },
    stopAtBeginningOfMainSubprogram = false,
  },
  {
    name = 'Select and attach to process',
    type = 'cppdbg',
    request = 'attach',
    program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file') end,
    pid = function()
      local name = vim.fn.input('Executable name (filter): ')
      return require('dap.utils').pick_process({ filter = name })
    end,
    cwd = '${workspaceFolder}',
  },
})

dap.configurations.cpp = dap.configurations.c
dap.configurations.rust = dap.configurations.c
