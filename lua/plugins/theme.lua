---@type packman.SpecItem[]
return {
  {
    'catppuccin/nvim',
    event = 'UIEnter',
    config = function()
      --- @param name string
      --- @param val vim.api.keyset.highlight
      local set_hl = function(name, val) vim.api.nvim_set_hl(0, name, val) end

      local palette = require('mini.base16').config.palette

      set_hl('AvanteSidebarWinSeparator', { fg = palette.base04, bg = 'NONE' })
      set_hl('AvanteSidebarWinHorizontalSeparator', { fg = palette.base04, bg = 'NONE' })
      set_hl('BlinkCmpLabel', { fg = palette.base07, bold = false })
      set_hl('BlinkCmpLabelMatch', { fg = palette.base0D, bold = true })
      set_hl('BlinkCmpMenuSelection', { fg = palette.base00, bg = palette.base0D })
      set_hl('Comment', { fg = palette.base04 })
      set_hl('NonText', { fg = palette.base04 })
      set_hl('NvimTreeCursorLine', { link = 'CursorLine' })
      set_hl('NvimTreeFolderIcon', { fg = palette.base0D })
      set_hl('SnacksPickerPrompt', { fg = palette.base09 })
      set_hl('SnacksPickerDir', { fg = palette.base04 })
      set_hl('SnacksTitle', { fg = palette.base00, bg = palette.base08 })
      set_hl('SnacksPickerToggle', { fg = palette.base00, bg = palette.base08 })
      set_hl('SnacksPickerTitle', { fg = palette.base00, bg = palette.base0B })
      set_hl('WinBarNc', { fg = palette.base04, bg = 'NONE' })
      set_hl('WinSeparator', { fg = palette.base03, bg = 'NONE' })

      local groups = {
        'DiagnosticFloatingOk', 'DiagnosticFloatingInfo', 'DiagnosticFloatingWarn',
        'DiagnosticFloatingError', 'DiagnosticFloatingHint', 'Folded',
        'GitSignsAdd', 'GitSignsChange', 'GitSignsDelete', 'GitSignsUntracked',
        'GitSignsStagedAdd', 'GitSignsStagedChange', 'GitSignsStagedDelete',
        'GitSignsStagedUntracked', 'MiniFilesTitleFocused', 'NormalFloat',
        'NormalNc', 'Pmenu', 'StatusLine', 'TabLineFill', 'WinBar',
      }
      for _, group in ipairs(groups) do
        local hl = vim.tbl_extend('force', vim.api.nvim_get_hl(0, { name = group, link = false }), { bg = 'NONE' })
        hl.default = hl.default == true and false or nil
        set_hl(group, hl)
      end
    end,
  },
}
