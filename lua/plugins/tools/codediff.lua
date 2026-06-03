vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    PackUtils.load({ name = 'codediff.nvim', deps = { 'nui.nvim' } }, function() require('codediff').setup() end)
  end,
})
