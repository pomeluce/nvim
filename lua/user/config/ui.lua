local bufferline = require('user.plugins.bufferline')
local lualine = require('user.plugins.lualine')
local indentline = require('user.plugins.indentline')
local gitsigns = require('user.plugins.gitsigns')
local dashboard = require('user.plugins.dashboard')
local nvimtree = require('user.plugins.nvim-tree')
local noice = require('user.plugins.noice')

return {
  -- buffer 标签
  {
    'akinsho/bufferline.nvim',
    event = 'BufWinEnter',
    opts = bufferline.setup(),
  },
  -- 状态栏插件
  {
    'nvim-lualine/lualine.nvim',
    event = 'BufWinEnter',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    opts = lualine.setup(),
  },
  -- inlineBlank 配置
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = 'BufRead',
    config = function()
      local hooks = require('ibl.hooks')
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, 'RainbowRed', { fg = '#E06C75' })
        vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = '#E5C07B' })
        vim.api.nvim_set_hl(0, 'RainbowBlue', { fg = '#61AFEF' })
        vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = '#D19A66' })
        vim.api.nvim_set_hl(0, 'RainbowGreen', { fg = '#98C379' })
        vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = '#C678DD' })
        vim.api.nvim_set_hl(0, 'RainbowCyan', { fg = '#56B6C2' })
      end)
      require('ibl').setup(indentline.setup())
    end,
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
    opts = gitsigns.setup(),
  },
  -- 启动面板
  {
    'glepnir/dashboard-nvim',
    opts = dashboard.setup(),
  },
  -- 文件树
  {
    'nvim-tree/nvim-tree.lua',
    event = 'VeryLazy',
    cmd = { 'NvimTreeToggle', 'NvimTreeFindFileToggle', 'NvimTreeOpen' },
    opts = nvimtree.setup(),
  },
  -- noice
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
      { 'rcarriga/nvim-notify', opts = { background_colour = '#000000' } },
    },
    opts = noice.setup(),
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
}
