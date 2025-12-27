return {
  -- 中文help doc
  { 'yianwillis/vimcdoc', event = 'VimEnter' },

  -- markdown 预览插件 导航生成插件
  { 'mzlogin/vim-markdown-toc', event = 'VeryLazy', ft = 'markdown' },
  { 'iamcco/markdown-preview.nvim', event = 'VeryLazy', build = 'cd app && yarn install', cmd = 'MarkdownPreview', ft = 'markdown' },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    event = 'VeryLazy',
    ft = { 'markdown', 'codecompanion' },
    init = function()
      -- 要预览的浏览器
      vim.g.mkdp_browser = require('akirc').file.markdown.browser or ''
      -- makedown 配色文件
      vim.g.mkdp_markdown_css = require('utils').cfg_path .. '/colors/github.css'
      -- 页面标题
      vim.g.mkdp_page_title = '${name}'
      -- 预览选项
      vim.g.mkdp_preview_options = { hide_yaml_meta = 1, disable_filename = 1 }
      -- 主题
      -- G.g.mkdp_theme = 'dark'
      -- 围栏标记
      vim.g.vmt_fence_text = 'markdown-toc'
    end,
    opts = { code = { language_icon = true } },
  },

  -- 代码注释
  {
    'numToStr/Comment.nvim',
    event = 'VeryLazy',
    dependencies = 'JoosepAlviste/nvim-ts-context-commentstring',
    config = function()
      require('Comment').setup {
        -- N 模式注释快捷键
        toggler = { line = '<leader>/', block = '<leader><leader>/' },
        -- V 模式注释快捷键
        opleader = { line = '<leader>/', block = '<leader><leader>/' },
        -- 启用快捷键
        mappings = { basic = true, extra = false },
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      }
      local ft = require('Comment.ft')
      -- 单独设置注释
      ft.set('java', { '// %s', '/* %s */' })
      ft.set('ini', { '; %s' })
    end,
  },

  -- 文档注释
  {
    'danymat/neogen',
    event = 'VeryLazy',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    opts = { enabled = true, input_after_comment = true },
  },

  -- 项目管理
  {
    'coffebar/neovim-project',
    dependencies = 'Shatur/neovim-session-manager',
    lazy = require('akirc').session.lazy_load,
    priority = 100,
    init = function()
      vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'
    end,
    opts = function()
      local akirc = require('akirc')
      return {
        projects = vim.list_extend({}, akirc.session.projects),
        datapath = vim.fn.stdpath('data'),
        -- 非项目目录加载最后一次会话
        last_session_on_startup = false,
        -- 仪表盘模式, 开启取消自动加载
        dashboard_mode = false,
        -- Timeout in milliseconds before trigger FileType autocmd after session load
        -- to make sure lsp servers are attached to the current buffer.
        -- Set to 0 to disable triggering FileType autocmd
        filetype_autocmd_timeout = 200,
        session_manager_opts = {
          -- 在保存会话之前, 这些文件类型的所有缓冲区都将关闭
          autosave_ignore_filetypes = { 'gitcommit', 'gitrebase' },
          -- 不会自动保存会话的目录列表
          autosave_ignore_dirs = vim.list_extend({ vim.fn.expand('~'), '/' }, akirc.session.ignore_dir),
        },
      }
    end,
  },

  -- 字符环绕
  { 'tpope/vim-surround', event = 'VeryLazy' },

  -- 快速跳转
  { 'folke/flash.nvim', event = 'VeryLazy', opts = { modes = { char = { enabled = false } } } },

  -- which-key
  {
    'folke/which-key.nvim',
    keys = { '<leader>', '"', "'", '`', 'c', 'v', 'g' },
    cmd = 'WhichKey',
    opts = function()
      dofile(vim.g.base46_cache .. 'whichkey')
      return { win = { border = require('akirc').ui.borderStyle, padding = { 1, 2, 1, 2 } }, layout = { width = { min = 20, max = 50 }, spacing = 3 } }
    end,
  },

  -- 翻译插件
  {
    'uga-rosa/translate.nvim',
    event = 'VeryLazy',
    init = function()
      -- 目标语言
      vim.g.translator_target_lang = 'zh'
      -- 源语言
      vim.g.translator_source_lang = 'auto'
      -- 翻译引擎
      vim.g.translator_default_engines = { 'google' }
      -- 边框
      vim.g.translator_window_borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' }
    end,
  },

  -- 标签闭合
  {
    'windwp/nvim-ts-autotag',
    event = 'VeryLazy',
    opts = { opts = { enable_rename = true, enable_close = true, enable_close_on_slash = true } },
  },
}
