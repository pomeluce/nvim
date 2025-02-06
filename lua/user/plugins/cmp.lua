local cfg = require('user.configs.cmp')

return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-cmdline',
    'onsails/lspkind.nvim',
    -- copilot 智能提示
    -- {
    --   'zbirenbaum/copilot.lua',
    --   dependencies = {
    --     { 'zbirenbaum/copilot-cmp', main = 'copilot_cmp', opts = {} },
    --   },
    --   main = 'copilot',
    --   cmd = 'Copilot',
    --   event = 'InsertEnter',
    --   opts = require('user.configs.copilot').setup(),
    -- },
    --- codeium 智能提示
    {
      'jcdickinson/codeium.nvim',
      opts = require('user.configs.codeium').setup(),
    },
    {
      'saadparwaiz1/cmp_luasnip',
      event = 'InsertEnter',
      dependencies = {
        'L3MON4D3/LuaSnip',
        dependencies = {
          'rafamadriz/friendly-snippets',
        },
      },
    },
  },
  config = function()
    -- 预定义代码片段
    require('luasnip.loaders.from_vscode').lazy_load()
    -- 自定义代码片段
    require('luasnip.loaders.from_snipmate').lazy_load { paths = { './snippets' } }
    local cmp = require('cmp')
    cmp.setup(cfg.setup(cmp, require('cmp.types')))
    cfg.cmp_cmdline(cmp)
    vim.api.nvim_set_hl(0, 'CmpItemKindCopilot', { fg = '#4CCD99' })
    vim.api.nvim_set_hl(0, 'CmpItemKindCodeium', { fg = '#6CC644' })
  end,
}
