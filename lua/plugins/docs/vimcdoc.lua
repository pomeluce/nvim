vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function() PackUtils.load({ name = 'vimcdoc' }) end,
})
