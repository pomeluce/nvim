vim.pack.add({
  { src = 'https://github.com/brenoprata10/nvim-highlight-colors' },
})

vim.api.nvim_create_autocmd('UIEnter', {
  group = vim.api.nvim_create_augroup('SetupHighlightColor', { clear = true }),
  callback = function()
    require('nvim-highlight-colors').setup({
      render = 'virtual',
      virtual_symbol = '',
      enable_hex = true,
      enable_short_hex = true,
      enable_rgb = true,
      enable_hsl = true,
      enable_hsl_without_function = true,
      enable_var_usage = true,
      enable_named_colors = true,
      enable_tailwind = true,
    })
  end,
})
