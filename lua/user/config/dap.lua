return {
  'mfussenegger/nvim-dap',
  dependencies = {
    { 'rcarriga/nvim-dap-ui',            main = 'dapui', opts = {} },
    { 'theHamsta/nvim-dap-virtual-text', opts = {} },
    "nvim-telescope/telescope-dap.nvim",
  },
  config = function()
    require('user.dap.handlers')
  end
}
