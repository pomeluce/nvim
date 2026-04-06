---@type packman.SpecItem[]
return {
  {
    'brenoprata10/nvim-highlight-colors',
    event = 'UIEnter',
    opts = {
      render = 'virtual',
      virtual_symbol = '',
      enable_tailwind = true,
      exclude_filetypes = { 'blink-cmp-menu' },
    },
  },
}
