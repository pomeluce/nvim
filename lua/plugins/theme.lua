vim.api.nvim_create_autocmd('UIEnter', {
  group = vim.api.nvim_create_augroup('SetupTheme', { clear = true }),
  callback = function()
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
      'DiagnosticFloatingOk',
      'DiagnosticFloatingInfo',
      'DiagnosticFloatingWarn',
      'DiagnosticFloatingError',
      'DiagnosticFloatingHint',
      'Folded',
      'GitSignsAdd',
      'GitSignsChange',
      'GitSignsDelete',
      'GitSignsUntracked',
      'GitSignsStagedAdd',
      'GitSignsStagedChange',
      'GitSignsStagedDelete',
      'GitSignsStagedUntracked',
      'MiniFilesTitleFocused',
      'NormalFloat',
      'NormalNc',
      'Pmenu',
      'StatusLine',
      'TabLineFill',
      'WinBar',
    }
    for _, group in ipairs(groups) do
      local hl = vim.tbl_extend('force', vim.api.nvim_get_hl(0, { name = group, link = false }), { bg = 'NONE' })
      hl.default = hl.default == true and false or nil
      set_hl(group, hl)
    end
  end,
})

---@type packman.SpecItem[]
return {
  {
    'nvim-mini/mini.base16',
    enabled = require('utils').settings('theme.enable') or false,
    config = function()
      require('mini.base16').setup({
        palette = {
          base00 = '#2b2b2b',
          base01 = '#505050',
          base02 = '#555555',
          base03 = '#5a5a5a',
          base04 = '#999999',
          base05 = '#b3b3b3',
          base06 = '#cccccc',
          base07 = '#e0e0e0',
          base08 = '#f07173',
          base09 = '#e69875',
          base0A = '#e2ae6a',
          base0B = '#99c983',
          base0C = '#60a673',
          base0D = '#78bdb4',
          base0E = '#d87595',
          base0F = '#9d94d4',
        },
      })
      vim.cmd.highlight({ 'Normal', 'guibg=NONE', 'ctermbg=NONE' })
      vim.cmd.highlight({ 'NonText', 'guibg=NONE', 'ctermbg=NONE' })
      vim.cmd.highlight({ 'SignColumn', 'guibg=NONE', 'ctermbg=NONE' })
      vim.cmd.highlight({ 'LineNr', 'guibg=NONE', 'ctermbg=NONE' })
      vim.cmd.highlight({ 'LineNrAbove', 'guibg=NONE', 'ctermbg=NONE' })
      vim.cmd.highlight({ 'LineNrBelow', 'guibg=NONE', 'ctermbg=NONE' })
    end,
  },
}
