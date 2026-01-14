vim.pack.add({
  { src = 'https://github.com/mfussenegger/nvim-dap' },
  { src = 'https://github.com/rcarriga/nvim-dap-ui' },
  { src = 'https://github.com/theHamsta/nvim-dap-virtual-text' },
  { src = 'https://github.com/nvim-neotest/nvim-nio' },
})

local map = vim.keymap.set
local pattern = { 'c', 'cpp', 'java', 'javascript', 'javascriptreact', 'python', 'typescript', 'typescriptreact' }

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('SetupDebugging', { clear = true }),
  pattern = pattern,
  once = true,
  callback = function()
    -- 加载项目 dap 配置
    local dcp = vim.fn.getcwd() .. '/.nvim/dap.lua'
    if vim.fn.filereadable(dcp) == 1 then dofile(dcp) end

    require('configs.adapters')

    require('nvim-dap-virtual-text').setup()

    local dap, dapui = require('dap'), require('dapui')
    dap.listeners.before.attach.dapui_config = function() dapui.open() end
    dap.listeners.before.launch.dapui_config = function() dapui.open() end
    dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
    dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

    dapui.setup({
      expand_lines = false,
      layouts = {
        {
          position = 'left',
          size = 0.2,
          elements = { { id = 'stacks', size = 0.2 }, { id = 'scopes', size = 0.5 }, { id = 'breakpoints', size = 0.15 }, { id = 'watches', size = 0.15 } },
        },
        {
          position = 'bottom',
          size = 0.2,
          elements = { { id = 'repl', size = 0.3 }, { id = 'console', size = 0.7 } },
        },
      },
    })

    vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DapBreakpoint', linehl = '', numhl = 'DapBreakpoint' })
    vim.fn.sign_define('DapBreakpointCondition', { text = '', texthl = 'DapBreakpointCondition', linehl = 'DapBreakpointCondition', numhl = 'DapBreakpointCondition' })
    vim.fn.sign_define('DapBreakpointRejected', { text = '󰃤', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
    vim.fn.sign_define('DapStopped', { text = '', texthl = 'DapStopped', linehl = 'DapStopped', numhl = 'DapStopped' })
    vim.fn.sign_define('DapLogPoint', { text = '', texthl = 'DapLogPoint', linehl = 'DapLogPoint', numhl = 'DapLogPoint' })

    -- keymaps
    map('n', '<leader>du', function() dapui.toggle({ reset = true }) end, { desc = 'DAP: Toggle UI' })
    map('n', '<F1>', function() dapui.toggle({ reset = true }) end, { desc = 'DAP: Toggle UI' })
    map('n', '<leader>ds', dap.continue, { desc = ' Start/Continue' })
    map('n', '<F2>', dap.continue, { desc = ' Start/Continue' })
    map('n', '<leader>di', dap.step_into, { desc = ' Step into' })
    map('n', '<F3>', dap.step_into, { desc = ' Step into' })
    map('n', '<leader>do', dap.step_over, { desc = ' Step over' })
    map('n', '<F4>', dap.step_over, { desc = ' Step over' })
    map('n', '<leader>dO', dap.step_out, { desc = ' Step out' })
    map('n', '<F5>', dap.step_out, { desc = ' Step out' })
    map('n', '<leader>dq', dap.close, { desc = 'DAP: Close session' })
    map('n', '<leader>dr', dap.restart_frame, { desc = 'DAP: Restart frame' })
    map('n', '<F6>', dap.restart, { desc = 'DAP: Start over' })
    map('n', '<leader>dQ', dap.terminate, { desc = ' Terminate session' })
    map('n', '<F7>', dap.terminate, { desc = ' Terminate session' })
    map('n', '<leader>dc', dap.run_to_cursor, { desc = 'DAP: Run to Cursor' })
    map('n', '<leader>dR', dap.repl.toggle, { desc = 'DAP: Toggle REPL' })
    map('n', '<leader>dh', require('dap.ui.widgets').hover, { desc = 'DAP: Hover' })
    map('n', '<leader>db', dap.toggle_breakpoint, { desc = 'DAP: Breakpoint' })
    map('n', '<leader>dB', function() dap.set_breakpoint(vim.fn.input('Condition for breakpoint:')) end, { desc = 'DAP: Conditional Breakpoint' })
    map('n', '<leader>dD', dap.clear_breakpoints, { desc = 'DAP: Clear Breakpoints' })
  end,
})
