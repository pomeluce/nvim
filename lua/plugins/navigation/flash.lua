vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    PackUtils.load({ name = 'flash.nvim' }, function() require('flash').setup({ modes = { char = { enabled = false } } }) end)
  end,
})
