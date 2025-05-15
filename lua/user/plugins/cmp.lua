return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
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
      'Exafunction/windsurf.nvim',
      name = 'codeium',
      opts = require('user.configs.windsurf').setup(),
    },
    {
      'L3MON4D3/LuaSnip',
      dependencies = { 'rafamadriz/friendly-snippets' },
      opts = { history = true, updateevents = 'TextChanged,TextChangedI' },
    },
    {
      'windwp/nvim-autopairs',
      opts = require('user.configs.autopairs').setup(),
      config = function(_, opts)
        require('nvim-autopairs').setup(opts)
        -- setup cmp for autopairs
        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        require('cmp').event:on('confirm_done', cmp_autopairs.on_confirm_done())
      end,
    },
    -- cmp sources plugins
    {
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-cmdline',
      'saadparwaiz1/cmp_luasnip',
      {
        {
          'MattiasMTS/cmp-dbee',
          dependencies = {
            { 'kndndrj/nvim-dbee' },
          },
          ft = 'sql', -- optional but good to have
          opts = {}, -- needed
        },
      },
    },
  },
  config = function()
    local cmp = require('cmp')
    local cfg = require('user.configs.cmp')
    cfg.luasnip()
    cmp.setup(cfg.setup(cmp, require('cmp.types')))
    cfg.cmp_cmdline(cmp)
    vim.api.nvim_set_hl(0, 'CmpItemKindCopilot', { fg = '#4CCD99' })
    vim.api.nvim_set_hl(0, 'CmpItemKindCodeium', { fg = '#6CC644' })
  end,
}
