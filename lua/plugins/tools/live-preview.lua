vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function() PackUtils.load({ name = 'live-preview.nvim' }) end,
})
