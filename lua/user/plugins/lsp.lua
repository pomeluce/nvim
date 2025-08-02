return {
  {
    'williamboman/mason.nvim',
    cmd = { 'Mason', 'MasonInstall', 'MasonUpdate' },
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
      'jay-babu/mason-nvim-dap.nvim',
    },
    config = require('user.lsp.mason').setup(),
  },

  {
    'neovim/nvim-lspconfig',
    event = 'User FilePost',
    dependencies = {
      { 'folke/neoconf.nvim', opts = {} },
      { 'folke/neodev.nvim', opts = {} },
      { 'nvimdev/lspsaga.nvim', opts = require('user.configs.lspsaga').setup() },
    },
    init = require('user.lsp.handlers').init(),
    config = require('user.lsp.handlers').setup(),
  },

  {
    'stevearc/aerial.nvim',
    event = 'VeryLazy',
    opts = require('user.configs.aerial').setup(),
  },
}
