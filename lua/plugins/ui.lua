return {
  -- 彩虹缩进和括号
  {
    'lukas-reineke/indent-blankline.nvim',
    dependencies = { 'TheGLander/indent-rainbowline.nvim', 'HiPhish/rainbow-delimiters.nvim' },
    event = 'User FilePost',
    config = function()
      dofile(vim.g.base46_cache .. 'blankline')

      local hooks = require('ibl.hooks')
      -- hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, 'RainbowBlue', { default = true, fg = '#61AFEF', ctermfg = 'Blue' })
        vim.api.nvim_set_hl(0, 'RainbowViolet', { default = true, fg = '#C678DD', ctermfg = 'Magenta' })
        vim.api.nvim_set_hl(0, 'RainbowRed', { default = true, fg = '#E06C75', ctermfg = 'Red' })
        vim.api.nvim_set_hl(0, 'RainbowYellow', { default = true, fg = '#E5C07B', ctermfg = 'Yellow' })
        vim.api.nvim_set_hl(0, 'RainbowGreen', { default = true, fg = '#98C379', ctermfg = 'Green' })
        vim.api.nvim_set_hl(0, 'RainbowOrange', { default = true, fg = '#D19A66', ctermfg = 'White' })
        vim.api.nvim_set_hl(0, 'RainbowCyan', { default = true, fg = '#56B6C2', ctermfg = 'Cyan' })
      end)
      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

      local highlight = { 'RainbowBlue', 'RainbowViolet', 'RainbowRed', 'RainbowYellow', 'RainbowGreen', 'RainbowOrange', 'RainbowCyan' }
      require('ibl').setup({
        indent = { char = '│', highlight = 'IblChar' },
        scope = { char = '│', highlight = highlight },
      })
      vim.g.rainbow_delimiters = { query = { javascript = 'rainbow-parens', tsx = 'rainbow-parens', html = 'rainbow-parens' }, highlight = highlight }

      dofile(vim.g.base46_cache .. 'blankline')
    end,
  },

  {
    'folke/noice.nvim',
    event = 'User FilePost',
    dependencies = {
      'MunifTanjim/nui.nvim',
      { 'rcarriga/nvim-notify', opts = { background_colour = '#000000' } },
    },
    opts = {
      views = { cmdline_popup = { position = { row = 5, col = '50%' }, size = { width = '70%', height = 'auto' } } },
      cmdline = {
        enabled = true,
        view = 'cmdline_popup',
        opts = {},
        format = {
          cmdline = { pattern = '^:', icon = '', lang = 'vim' },
          search_down = { kind = 'search', pattern = '^/', icon = ' ', lang = 'regex' },
          search_up = { kind = 'search', pattern = '^%?', icon = ' ', lang = 'regex' },
          filter = { pattern = '^:%s*!', icon = '$', lang = 'bash' },
          lua = { pattern = { '^:%s*lua%s+', '^:%s*lua%s*=%s*', '^:%s*=%s*' }, icon = '', lang = 'lua' },
          help = { pattern = '^:%s*he?l?p?%s+', icon = '󰞋' },
          input = {}, -- Used by input()
        },
      },
      -- TIP: 如果打开 messages, cmdline 会被自动开启
      messages = { enabled = true, view = 'mini', view_error = 'notify', view_warn = 'notify', view_history = 'messages', view_search = 'virtualtext' },
      popupmenu = { enabled = true, backend = 'cmp' },
      notify = { enabled = false, view = 'notify' },
      lsp = { progress = { enabled = false } },
    },
  },

  {
    'RRethy/vim-illuminate',
    event = 'VeryLazy',
    config = function() require('illuminate').configure() end,
  },

  {
    'brenoprata10/nvim-highlight-colors',
    event = 'User FilePost',
    opts = { render = 'background', virtual_symbol = '■', enable_named_colors = true, enable_tailwind = true },
  },

  {
    'folke/todo-comments.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = function() require('configs.todo') end,
  },

  -- 折叠插件
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    init = function()
      vim.o.foldcolumn = '0' -- '1' 会侧边显示折叠数量
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    config = function()
      local ufo = require('ufo')
      ufo.setup({
        provider_selector = function() return { 'treesitter', 'indent' } end,
      })
    end,
  },
}
