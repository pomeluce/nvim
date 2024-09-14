return {
  'neovim/nvim-lspconfig',
  event = 'BufRead',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    { 'folke/neoconf.nvim', opts = {} },
    { 'folke/neodev.nvim', opts = {} },
    -- { 'j-hui/fidget.nvim', tag = 'legacy', event = 'LspAttach', opts = {} },
    { 'nvimdev/lspsaga.nvim', opts = require('user.configs.lspsaga').setup() },
  },
  init = require('user.lsp.handlers').sign_define,
  config = function()
    -- 加载 mason
    require('user.lsp.mason')
    -- 加载 lsp handlers
    require('user.lsp.handlers').setup()
  end,
}
