vim.pack.add({
  { src = 'https://github.com/folke/noice.nvim' },
  { src = 'https://github.com/MunifTanjim/nui.nvim' },
})

vim.api.nvim_create_autocmd('UIEnter', {
  group = vim.api.nvim_create_augroup('SetupNotice', { clear = true }),
  once = true,
  callback = function()
    require('noice').setup({
      views = {
        cmdline_popup = { position = { row = 10, col = '50%' }, size = { width = '40%', height = 'auto' } },
      },
      cmdline = {
        enabled = true,
        view = 'cmdline_popup',
        opts = {},
        format = {
          cmdline = { pattern = '^:', icon = ' ', lang = 'vim' },
          search_down = { kind = 'search', pattern = '^/', icon = '  ', lang = 'regex' },
          search_up = { kind = 'search', pattern = '^%?', icon = '  ', lang = 'regex' },
          filter = { pattern = '^:%s*!', icon = ' ', lang = 'bash' },
          lua = { pattern = { '^:%s*lua%s+', '^:%s*lua%s*=%s*', '^:%s*=%s*' }, icon = ' ', lang = 'lua' },
          help = { pattern = '^:%s*he?l?p?%s+', icon = '󰞋 ' },
          input = {},
        },
      },
      -- TIP: 如果打开 messages, cmdline 会被自动开启
      messages = { enabled = true, view = 'mini', view_error = 'notify', view_warn = 'notify', view_history = 'messages', view_search = 'virtualtext' },
      popupmenu = { enabled = true, backend = 'cmp' },
      presets = { lsp_doc_border = true },
      lsp = { progress = { enabled = false } },
    })
  end,
})
