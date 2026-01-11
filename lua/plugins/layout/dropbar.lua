vim.pack.add({
  { src = 'https://github.com/Bekaboo/dropbar.nvim' },
})

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  callback = function() require('dropbar').setup({ menu = { preview = false, scrollbar = { enable = true, background = false } } }) end,
})
