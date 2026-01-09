vim.pack.add({
  { src = 'https://github.com/brenoprata10/nvim-highlight-colors' },
})

vim.api.nvim_create_autocmd('UIEnter', {
  group = vim.api.nvim_create_augroup('SetupHighlightColor', { clear = true }),
  callback = function()
    require('nvim-highlight-colors').setup({
      render = 'background',
      virtual_symbol = '■',
      enable_named_colors = true,
      enable_tailwind = true,
    })
  end,
})
