return {
  'mfussenegger/nvim-dap',
  event = 'VeryLazy',
  dependencies = {
    { 'rcarriga/nvim-dap-ui', main = 'dapui', opts = {} },
    { 'nvim-neotest/nvim-nio' },
    { 'theHamsta/nvim-dap-virtual-text', opts = {} },
    'nvim-telescope/telescope-dap.nvim',
  },
  config = function()
    require('user.dap.handlers')
  end,
}
