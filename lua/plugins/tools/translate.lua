vim.pack.add({
  { src = 'https://github.com/uga-rosa/translate.nvim' },
})

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('SetupTranslate', { clear = true }),
  callback = function()
    require('translate').setup({
      default = { command = 'translate_shell' },
      preset = { command = { translate_shell = { args = { '-e', 'bing' } } } },
    })
  end,
})
