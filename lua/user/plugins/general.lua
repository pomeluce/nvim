local telescope = require('user.configs.telescope')
local comment = require('user.configs.comment')
-- local project = require('user.configs.project')
local session = require('user.configs.session')
local autopairs = require('user.configs.autopairs')
local flash = require('user.configs.flash')
local picker = require('user.configs.window-picker')
local whickkey = require('user.configs.whichkey')
local tabout = require('user.configs.tabout')
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
    event = 'VeryLazy',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-media-files.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      -- 项目管理
      -- {
      --   'ahmedkhalf/project.nvim',
      --   main = 'project_nvim',
      --   opts = project.setup(),
      -- },
      -- camelcase 命名转换
      { 'johmsalas/text-case.nvim', opts = {} },
    },
    config = function()
      local actions = require('telescope.actions')
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
    cond = function()
      local argv = vim.v.argv
      for _, arg in ipairs(argv) do
        if arg == '+CALLDB' then
          return false
        end
      end
      return true
    end,
    opts = session.setup(),
    event = 'VeryLazy',
    priority = 100,
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
    event = 'VeryLazy',
  },
  -- auot-pairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = autopairs.setup(),
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
  {
    'abecodes/tabout.nvim',
    event = 'InsertEnter',
    opts = tabout.setup(),
  },
  -- 标签闭合
  {
    'windwp/nvim-ts-autotag',
    event = 'VeryLazy',
    opts = autotag.setup(),
  },
}
