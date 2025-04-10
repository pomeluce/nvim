return {
  {
    'shellRaining/hlchunk.nvim',
    event = { 'UIEnter' },
    opts = require('user.configs.hlchunk').setup(),
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
    'antosha417/nvim-lsp-file-operations',
    dependencies = {
      'nvim-tree/nvim-tree.lua',
      cmd = { 'NvimTreeToggle', 'NvimTreeFindFileToggle', 'NvimTreeOpen', 'NvimTreeFocus' },
      opts = require('user.configs.nvim-tree').setup(),
    },
    config = function()
      require('lsp-file-operations').setup()
    end,
  },
  -- noice
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
      { 'rcarriga/nvim-notify', opts = { background_colour = '#000000' } },
    },
    opts = require('user.configs.noice').setup(),
  },
  --- 浮动终端
  { 'voldikss/vim-floaterm', event = 'VeryLazy' },
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
    event = 'VeryLazy',
    opts = require('user.configs.color-preview').setup(),
  },
  -- 待办高亮显示
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = require('user.configs.todo-comments').setup(),
  },
}
