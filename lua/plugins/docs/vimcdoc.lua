vim.pack.add({ { src = 'https://github.com/yianwillis/vimcdoc' } }, { load = false })

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('SetupVimcdoc', { clear = true }),
  once = true,
  callback = function() vim.pack.add({ { src = 'https://github.com/yianwillis/vimcdoc' } }) end,
})
