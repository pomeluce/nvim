return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    -- copilot 智能提示
    {
      'zbirenbaum/copilot.lua',
      dependencies = { { 'zbirenbaum/copilot-cmp', main = 'copilot_cmp', opts = {} } },
      main = 'copilot',
      cmd = 'Copilot',
      event = 'InsertEnter',
      opts = { suggestion = { enabled = false }, panel = { enabled = false } },
    },
    {
      'L3MON4D3/LuaSnip',
      dependencies = { 'rafamadriz/friendly-snippets' },
      opts = { history = true, updateevents = 'TextChanged,TextChangedI' },
    },
    {
      'windwp/nvim-autopairs',
      config = function()
        require('nvim-autopairs').setup {
          fast_wrap = {},
          disable_filetype = { 'TelescopePrompt', 'vim' },
          check_ts = true,
          ts_config = {
            -- 不在该节点添加 autopairs
            lua = { 'string', 'source' },
            javascript = { 'template_string' },
            -- 不对 java 进行 treesitter 检查
            java = false,
          },
        }
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
    },
  },
  config = function()
    require('configs.completion')
  end,
}
