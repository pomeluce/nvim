vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    PackUtils.load({ name = 'nvim-surround' }, function() require('nvim-surround').setup({}) end)
  end,
})
