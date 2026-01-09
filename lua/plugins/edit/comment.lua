vim.pack.add({
  { src = 'https://github.com/numToStr/Comment.nvim' },
  { src = 'https://github.com/JoosepAlviste/nvim-ts-context-commentstring' },
})

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('SetupComment', { clear = true }),
  callback = function()
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
})
