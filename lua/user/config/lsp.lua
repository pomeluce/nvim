local lspsaga = require('user.plugins.lspsaga')

return {
  'neovim/nvim-lspconfig',
  event = 'VeryLazy',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    { 'folke/neoconf.nvim', opts = {} },
    { 'folke/neodev.nvim', opts = {} },
    -- { 'j-hui/fidget.nvim', tag = 'legacy', event = 'LspAttach', opts = {} },
    { 'nvimdev/lspsaga.nvim', opts = lspsaga.setup() },
  },
  config = function()
    -- 加载 mason
    require('user.lsp.mason')
    -- 加载 lsp handlers
    require('user.lsp.handlers').setup()
  end,
}
