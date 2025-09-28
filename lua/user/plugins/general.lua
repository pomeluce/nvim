local comment = require('user.configs.comment')
local flash = require('user.configs.flash')
local picker = require('user.configs.window-picker')
local whickkey = require('user.configs.whichkey')
local autotag = require('user.configs.autotag')

return {
  -- 中文help doc
  {
    'yianwillis/vimcdoc',
    event = 'VimEnter',
  },
  -- 全局文件搜索
  {
    'nvim-telescope/telescope.nvim',
    lazy = false,
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-media-files.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      -- camelcase 命名转换
      { 'johmsalas/text-case.nvim' },
    },
    config = require('user.configs.telescope').setup(),
  },
  -- markdown 预览插件 导航生成插件
  { 'mzlogin/vim-markdown-toc', event = 'VeryLazy', ft = 'markdown' },
  {
    'iamcco/markdown-preview.nvim',
    event = 'VeryLazy',
    build = 'cd app && yarn install',
    cmd = 'MarkdownPreview',
    ft = 'markdown',
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    event = 'VeryLazy',
    ft = { 'markdown', 'codecompanion' },
    opts = require('user.configs.markdown').setup(),
  },
  -- 代码注释
  {
    'numToStr/Comment.nvim',
    event = 'VeryLazy',
    dependencies = 'JoosepAlviste/nvim-ts-context-commentstring',
    config = comment.setup().comment,
  },
  -- 文档注释
  {
    'danymat/neogen',
    event = 'VeryLazy',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    opts = comment.setup().neogen,
  },
  -- 项目管理
  {
    'coffebar/neovim-project',
    dependencies = 'Shatur/neovim-session-manager',
    lazy = require('akirc').session.lazy_load,
    priority = 100,
    opts = require('user.configs.session').setup(),
  },
  -- 字符环绕
  {
    'tpope/vim-surround',
    event = 'VeryLazy',
  },
  -- 快速跳转
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = flash.setup(),
  },
  -- which-key
  {
    'folke/which-key.nvim',
    keys = { '<leader>', '"', "'", '`', 'c', 'v', 'g' },
    cmd = 'WhichKey',
    opts = whickkey.setup(),
  },
  -- window picker 快速切换窗口
  {
    's1n7ax/nvim-window-picker',
    name = 'window-picker',
    event = 'VeryLazy',
    version = '2.*',
    opts = picker.setup(),
  },
  -- 翻译插件
  {
    'uga-rosa/translate.nvim',
    event = 'VeryLazy',
  },
  -- 标签闭合
  {
    'windwp/nvim-ts-autotag',
    event = 'VeryLazy',
    opts = autotag.setup(),
  },
}
