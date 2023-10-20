local telescope = require('user.plugins.telescope')
local comment = require('user.plugins.comment')
local project = require('user.plugins.project')
local persistence = require('user.plugins.persistence')
local autopairs = require('user.plugins.autopairs')
local flash = require('user.plugins.flash')
local picker = require('user.plugins.window-picker')
local whickkey = require('user.plugins.whichkey')

return {
  -- 中文help doc
  {
    'yianwillis/vimcdoc',
    event = 'VimEnter',
  },
  -- 全局文件搜索
  {
    'nvim-telescope/telescope.nvim',
    event = 'VeryLazy',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-media-files.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      -- 项目管理
      {
        'ahmedkhalf/project.nvim',
        main = 'project_nvim',
        opts = project.setup(),
      },
      -- camelcase 命名转换
      { 'johmsalas/text-case.nvim' },
    },
    config = function()
      local actions = require('telescope.actions')
      require('telescope').setup(telescope.setup(actions))
      require('telescope').load_extension('media_files')
      require('telescope').load_extension('fzf')
      require('telescope').load_extension('projects')
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
    opts = comment.setup(),
    config = function(_, opts)
      require('Comment').setup(opts)
      local ft = require('Comment.ft')
      -- 单独设置注释
      ft.set('java', { '// %s', '/* %s */' })
      ft.set('ini', { '; %s' })
    end,
    event = 'BufRead',
  },
  -- 文档注释
  {
    'danymat/neogen',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    opts = comment.docSetup(),
    event = 'BufRead',
  },
  -- session 管理
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = persistence.setup(),
  },
  -- 数据库管理
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod', cmd = { 'DBUI' } },
    },
  },
  -- 字符环绕
  {
    'tpope/vim-surround',
    event = 'BufRead',
  },
  -- auot-pairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = autopairs.setup(),
  },
  -- 移动加速
  { 'rhysd/accelerated-jk' },
  -- 快速跳转
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = flash.setup(),
  },
  -- which-key
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
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
  -- tabout
  -- {
  --   "abecodes/tabout.nvim",
  --   event = "InsertEnter",
  --   opts = tabout.setup(),
  -- },
}
