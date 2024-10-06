return {
  -- 图标
  'nvim-tree/nvim-web-devicons',
  -- buffer 标签
  -- {
  --   'akinsho/bufferline.nvim',
  --   event = 'BufWinEnter',
  --   opts = require('user.configs.bufferline').setup(),
  -- },
  -- 状态栏插件
  {
    'rebelot/heirline.nvim',
    event = 'BufWinEnter',
    config = function()
      local heirline = require('user.configs.heirline')
      require('heirline').setup(heirline.setup())
    end,
  },
  {
    'shellRaining/hlchunk.nvim',
    event = { 'UIEnter' },
    opts = require('user.configs.hlchunk').setup(),
  },
  -- 面包屑
  {
    'utilyre/barbecue.nvim',
    name = 'barbecue',
    version = '*',
    event = 'VeryLazy',
    dependencies = {
      'SmiteshP/nvim-navic',
    },
    opts = {},
  },
  -- git 状态管理
  {
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    opts = require('user.configs.gitsigns').setup(),
  },
  -- 启动面板
  {
    'glepnir/dashboard-nvim',
    opts = require('user.configs.dashboard').setup(),
  },
  -- 文件树
  {
    'antosha417/nvim-lsp-file-operations',
    event = 'VeryLazy',
    dependencies = {
      'nvim-tree/nvim-tree.lua',
      cmd = { 'NvimTreeToggle', 'NvimTreeFindFileToggle', 'NvimTreeOpen' },
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
}
