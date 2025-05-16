local telescope = require('user.configs.telescope')
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
    config = function()
      local actions = require('telescope.actions')
      require('textcase').setup {}
      require('telescope').setup(telescope.setup(actions))
      require('telescope').load_extension('media_files')
      require('telescope').load_extension('ui-select')
      require('telescope').load_extension('fzf')
      require('telescope').load_extension('textcase')
    end,
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
  -- 代码注释
  {
    'numToStr/Comment.nvim',
    dependencies = 'JoosepAlviste/nvim-ts-context-commentstring',
    config = function()
      local pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
      require('Comment').setup(comment.setup(pre_hook))
      local ft = require('Comment.ft')
      -- 单独设置注释
      ft.set('java', { '// %s', '/* %s */' })
      ft.set('ini', { '; %s' })
    end,
    event = 'VeryLazy',
  },
  -- 文档注释
  {
    'danymat/neogen',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    opts = comment.docSetup(),
    event = 'VeryLazy',
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
    'voldikss/vim-translator',
    event = 'VeryLazy',
  },
  -- 标签闭合
  {
    'windwp/nvim-ts-autotag',
    event = 'VeryLazy',
    opts = autotag.setup(),
  },
}
