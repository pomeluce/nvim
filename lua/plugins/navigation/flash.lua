vim.pack.add({
  { src = 'https://github.com/folke/flash.nvim' },
})

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('SetupFlash', { clear = true }),
  callback = function() require('flash').setup({ modes = { char = { enabled = false } } }) end,
})
