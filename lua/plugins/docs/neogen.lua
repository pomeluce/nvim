vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    PackUtils.load({ name = 'neogen' }, function() require('neogen').setup({ enabled = true, input_after_comment = true }) end)
  end,
})
