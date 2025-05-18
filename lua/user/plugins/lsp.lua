return {
  {
    'williamboman/mason.nvim',
    cmd = { 'Mason', 'MasonInstall', 'MasonUpdate' },
    enabled = require('akirc').mason.enable,
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
      'jay-babu/mason-nvim-dap.nvim',
    },
    config = function()
      require('user.lsp.mason').setup()
    end,
  },

  {
    'neovim/nvim-lspconfig',
    event = 'User FilePost',
    dependencies = {
      { 'folke/neoconf.nvim', opts = {} },
      { 'folke/neodev.nvim', opts = {} },
      { 'nvimdev/lspsaga.nvim', opts = require('user.configs.lspsaga').setup() },
    },
    init = require('user.lsp.handlers').lsp_initialize,
    config = function()
      -- 加载 lsp handlers
      require('user.lsp.handlers').setup()
    end,
  },

  {
    'stevearc/aerial.nvim',
    event = 'VeryLazy',
    opts = require('user.configs.aerial').setup(),
  },
}
