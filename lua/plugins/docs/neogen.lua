vim.pack.add({
  { src = 'https://github.com/danymat/neogen' },
})

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('SetupNeogen', { clear = true }),
  callback = function() require('neogen').setup({ enabled = true, input_after_comment = true }) end,
})
