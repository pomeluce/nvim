local cmp_conf = require('user.plugins.cmp')
local copilot = require('user.plugins.copilot')

return {
  'hrsh7th/nvim-cmp',
  event = 'VeryLazy',
  dependencies = {
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-cmdline',
    'onsails/lspkind.nvim',
    -- copilot 智能提示
    {
      'zbirenbaum/copilot.lua',
      dependencies = {
        { 'zbirenbaum/copilot-cmp', main = 'copilot_cmp', opts = {} },
      },
      main = 'copilot',
      cmd = 'Copilot',
      event = 'InsertEnter',
      opts = copilot.setup,
    },
    {
      'saadparwaiz1/cmp_luasnip',
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
    cmp.setup(cmp_conf.setup(cmp))
    cmp_conf.cmp_cmdline(cmp)
    vim.api.nvim_set_hl(0, 'CmpItemKindCopilot', { fg = '#6CC644' })
  end,
}
