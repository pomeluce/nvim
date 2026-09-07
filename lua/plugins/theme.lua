PackUtils.load({ name = 'base16-nvim' }, function()
  require('base16-colorscheme').setup({
    base00 = '#2b2a29',
    base01 = '#3b3938',
    base02 = '#4d4a48',
    base03 = '#706b68',
    base04 = '#96918e',
    base05 = '#b8b4b1',
    base06 = '#d0ccca',
    base07 = '#e5e1df',
    base08 = '#ed7779',
    base09 = '#df9a77',
    base0A = '#d9ad70',
    base0B = '#98c379',
    base0C = '#70ad84',
    base0D = '#78b8b0',
    base0E = '#d47b9a',
    base0F = '#a197cf',
  })
  vim.cmd.highlight({ 'Normal', 'guibg=NONE', 'ctermbg=NONE' })
  vim.cmd.highlight({ 'NonText', 'guibg=NONE', 'ctermbg=NONE' })
  vim.cmd.highlight({ 'SignColumn', 'guibg=NONE', 'ctermbg=NONE' })
  vim.cmd.highlight({ 'LineNr', 'guibg=NONE', 'ctermbg=NONE' })
  vim.cmd.highlight({ 'LineNrAbove', 'guibg=NONE', 'ctermbg=NONE' })
  vim.cmd.highlight({ 'LineNrBelow', 'guibg=NONE', 'ctermbg=NONE' })
end)

--- @param name string
--- @param val vim.api.keyset.highlight
local set_hl = function(name, val) vim.api.nvim_set_hl(0, name, val) end

vim.api.nvim_create_autocmd('UIEnter', {
  group = vim.api.nvim_create_augroup('SetupTheme', { clear = true }),
  callback = function()
    local palette = require('base16-colorscheme').colors

    set_hl('AvanteSidebarWinSeparator', { fg = palette.base04, bg = 'NONE' })
    set_hl('AvanteSidebarWinHorizontalSeparator', { fg = palette.base04, bg = 'NONE' })
    set_hl('BlinkCmpLabel', { fg = palette.base05, bold = false })
    set_hl('BlinkCmpLabelMatch', { fg = palette.base0D, bold = true })
    set_hl('BlinkCmpMenu', { fg = palette.base05, bg = 'NONE' })
    set_hl('BlinkCmpMenuBorder', { fg = palette.base03, bg = 'NONE' })
    set_hl('BlinkCmpMenuSelection', { fg = palette.base00, bg = palette.base0D })
    set_hl('BlinkCmpDoc', { fg = palette.base05, bg = 'NONE' })
    set_hl('BlinkCmpDocBorder', { fg = palette.base03, bg = 'NONE' })
    set_hl('BlinkCmpDocSeparator', { fg = palette.base03, bg = 'NONE' })
    set_hl('BlinkCmpDocCursorLine', { fg = palette.base05, bg = 'NONE' })
    set_hl('BlinkCmpSignatureHelp', { fg = palette.base05, bg = 'NONE' })
    set_hl('BlinkCmpSignatureHelpBorder', { fg = palette.base03, bg = 'NONE' })
    set_hl('BlinkCmpSignatureHelpActiveParameter', { fg = palette.base0D, bg = 'NONE', bold = true })
    set_hl('Comment', { fg = palette.base04, italic = true })
    set_hl('@comment', { link = 'Comment' })
    set_hl('TSComment', { link = 'Comment' })
    set_hl('CursorLineNr', { fg = palette.base0A, bold = true })
    set_hl('DiagnosticError', { fg = palette.base08 })
    set_hl('DiagnosticWarn', { fg = palette.base0A })
    set_hl('DiagnosticInfo', { fg = palette.base0D })
    set_hl('DiagnosticHint', { fg = palette.base0C })
    set_hl('DiagnosticOk', { fg = palette.base0B })
    set_hl('DiagnosticFloatingError', { fg = palette.base08, bg = 'NONE' })
    set_hl('DiagnosticFloatingWarn', { fg = palette.base0A, bg = 'NONE' })
    set_hl('DiagnosticFloatingInfo', { fg = palette.base0D, bg = 'NONE' })
    set_hl('DiagnosticFloatingHint', { fg = palette.base0C, bg = 'NONE' })
    set_hl('DiagnosticFloatingOk', { fg = palette.base0B, bg = 'NONE' })
    set_hl('FloatBorder', { fg = palette.base03, bg = 'NONE' })
    set_hl('FloatTitle', { fg = palette.base0D, bg = 'NONE', bold = true })
    set_hl('JavaRunnerTab', { fg = palette.base04, bg = palette.base01 })
    set_hl('LineNr', { fg = palette.base03, bg = 'NONE' })
    set_hl('LineNrAbove', { link = 'LineNr' })
    set_hl('LineNrBelow', { link = 'LineNr' })
    set_hl('MiniFilesTitle', { fg = palette.base04, bg = 'NONE' })
    set_hl('MiniFilesTitleFocused', { fg = palette.base0D, bg = 'NONE', bold = true })
    set_hl('NonText', { fg = palette.base03 })
    set_hl('NormalFloat', { fg = palette.base05, bg = 'NONE' })
    set_hl('NvimTreeCursorLine', { link = 'CursorLine' })
    set_hl('NvimTreeFolderIcon', { fg = palette.base0D })
    set_hl('Pmenu', { fg = palette.base05, bg = 'NONE' })
    set_hl('PmenuSel', { fg = palette.base07, bg = palette.base02, bold = true })
    set_hl('SnacksPickerPrompt', { fg = palette.base0D, bold = true })
    set_hl('SnacksPickerDir', { fg = palette.base04 })
    set_hl('SnacksTitle', { fg = palette.base00, bg = palette.base0D, bold = true })
    set_hl('SnacksPickerToggle', { fg = palette.base00, bg = palette.base0D, bold = true })
    set_hl('SnacksPickerTitle', { fg = palette.base00, bg = palette.base0D, bold = true })
    set_hl('WinBarNc', { fg = palette.base04, bg = 'NONE' })
    set_hl('WinSeparator', { fg = palette.base03, bg = 'NONE' })
    set_hl('TreesitterContext', { link = 'FloatBorder' })
    set_hl('TabLine', { fg = palette.base04 })

    local groups = {
      'Folded',
      'GitSignsAdd',
      'GitSignsChange',
      'GitSignsDelete',
      'GitSignsUntracked',
      'GitSignsStagedAdd',
      'GitSignsStagedChange',
      'GitSignsStagedDelete',
      'GitSignsStagedUntracked',
      'NormalNc',
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
