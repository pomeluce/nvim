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
      vim.g.mkdp_markdown_css = vim.fn.stdpath('config') .. '/colors/github.css'
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

  -- 文档注释
  {
    'danymat/neogen',
    event = 'VeryLazy',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    opts = { enabled = true, input_after_comment = true },
  },
}
