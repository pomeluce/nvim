vim.pack.add({
  { src = 'https://github.com/kylechui/nvim-surround' },
})

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('SetupSurround', { clear = true }),
  callback = function() require('nvim-surround').setup({}) end,
})
