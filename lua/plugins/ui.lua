return {
  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'User FilePost',
    config = function()
      dofile(vim.g.base46_cache .. 'blankline')

      local hooks = require('ibl.hooks')
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
      require('ibl').setup {
        indent = { char = '│', highlight = 'IblChar' },
        scope = { char = '│', highlight = 'IblScopeChar' },
      }

      dofile(vim.g.base46_cache .. 'blankline')
    end,
  },

  {
    'Bekaboo/dropbar.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
    opts = {
      menu = {
        preview = false,
        win_configs = { border = require('akirc').ui.borderStyle },
        scrollbar = { enable = true, background = false },
      },
    },
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
    config = function()
      require('illuminate').configure()
    end,
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
    opts = function()
      require('configs.todo')
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'master' },
      'nvim-treesitter/nvim-treesitter-context',
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    build = ':TSUpdate',
    config = function()
      require('configs.treesitter')
    end,
  },
}
