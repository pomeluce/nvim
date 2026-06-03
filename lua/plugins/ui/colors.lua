vim.api.nvim_create_autocmd('UIEnter', {
  once = true,
  callback = function()
    PackUtils.load(
      { name = 'nvim-highlight-colors' },
      function()
        require('nvim-highlight-colors').setup({
          render = 'virtual',
          virtual_symbol = '',
          enable_tailwind = true,
          exclude_filetypes = { 'blink-cmp-menu' },
        })
      end
    )
  end,
})
