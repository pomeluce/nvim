return {
  -- 代码注释
  {
    'numToStr/Comment.nvim',
    event = 'VeryLazy',
    dependencies = 'JoosepAlviste/nvim-ts-context-commentstring',
    config = function()
      require('Comment').setup({
        -- N 模式注释快捷键
        toggler = { line = '<leader>/', block = '<leader><leader>/' },
        -- V 模式注释快捷键
        opleader = { line = '<leader>/', block = '<leader><leader>/' },
        -- 启用快捷键
        mappings = { basic = true, extra = false },
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      })
      local ft = require('Comment.ft')
      -- 单独设置注释
      ft.set('java', { '// %s', '/* %s */' })
      ft.set('ini', { '; %s' })
    end,
  },

  -- 字符环绕
  { 'tpope/vim-surround', event = 'VeryLazy' },

  -- 标签闭合
  {
    'windwp/nvim-ts-autotag',
    event = { 'BufReadPre', 'BufNewFile', 'InsertEnter' },
    opts = { opts = { enable_rename = true, enable_close = true, enable_close_on_slash = true } },
  },
}
