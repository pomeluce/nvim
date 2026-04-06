---@type packman.SpecItem[]
return {
  {
    'nvim-mini/mini.files',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      _G.MiniFiles = require('mini.files')
      MiniFiles.setup({
        mappings = { close = '<esc>', go_in_plus = '<cr>', synchronize = 'S' },
        windows = { width_focus = 25, width_nofocus = 20 },
      })
      vim.keymap.set('n', '<bs>', MiniFiles.open, { desc = 'Open mini file explorer' })
    end,
  },
}
