vim.pack.add({
  { src = 'https://github.com/brenoprata10/nvim-highlight-colors' },
})

vim.api.nvim_create_autocmd('UIEnter', {
  group = vim.api.nvim_create_augroup('SetupHighlightColor', { clear = true }),
  callback = function()
    require('nvim-highlight-colors').setup({
      render = 'virtual',
      virtual_symbol = '',
      enable_tailwind = true,
      exclude_filetypes = { 'blink-cmp-menu' },
    })
  end,
})
