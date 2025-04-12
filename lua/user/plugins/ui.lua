return {
  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'User FilePost',
    opts = require('user.configs.blankline').setup(),
    config = function(_, opts)
      dofile(vim.g.base46_cache .. 'blankline')

      local hooks = require('ibl.hooks')
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
      require('ibl').setup(opts)

      dofile(vim.g.base46_cache .. 'blankline')
    end,
  },
  -- 面包屑
  {
    'Bekaboo/dropbar.nvim',
    event = 'User FilePost',
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
    opts = require('user.configs.dropbar').setup(),
  },
  -- git 状态管理
  {
    'lewis6991/gitsigns.nvim',
    event = 'User FilePost',
    opts = require('user.configs.gitsigns').setup(),
  },
  -- 文件树
  {
    'nvim-tree/nvim-tree.lua',
    cmd = { 'NvimTreeToggle', 'NvimTreeFindFileToggle', 'NvimTreeOpen', 'NvimTreeFocus' },
    opts = require('user.configs.nvim-tree').setup(),
  },
  {
    'antosha417/nvim-lsp-file-operations',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-tree.lua' },
    config = function()
      require('lsp-file-operations').setup()
    end,
  },
  -- noice
  {
    'folke/noice.nvim',
    event = 'User FilePost',
    dependencies = {
      'MunifTanjim/nui.nvim',
      { 'rcarriga/nvim-notify', opts = { background_colour = '#000000' } },
    },
    opts = require('user.configs.noice').setup(),
  },
  --- 终端
  {
    'akinsho/toggleterm.nvim',
    event = 'VeryLazy',
    opts = require('user.configs.toggleterm').setup(),
  },
  -- 高亮光标所在单词
  {
    'RRethy/vim-illuminate',
    event = 'VeryLazy',
    config = function()
      require('illuminate').configure()
    end,
  },
  -- 颜色显示
  {
    'brenoprata10/nvim-highlight-colors',
    event = 'User FilePost',
    opts = require('user.configs.hlcolor').setup(),
  },
  -- 待办高亮显示
  {
    'folke/todo-comments.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = require('user.configs.todo-comments').setup(),
  },
}
