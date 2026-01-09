vim.pack.add({
  { src = 'https://github.com/nvim-mini/mini.icons' },
})

require('mini.icons').setup({
  style = 'glyph',
  file = {
    README = { glyph = '󰂺', hl = 'MiniIconsYellow' },
    ['README.md'] = { glyph = '󰂺', hl = 'MiniIconsWhite' },
    ['.prettierrc.json'] = { glyph = '', hl = 'MiniIconsBlue' },
  },
  filetype = {
    bash = { glyph = '󱆃', hl = 'MiniIconsGreen' },
    sh = { glyph = '󱆃', hl = 'MiniIconsGrey' },
    toml = { glyph = '󱄽', hl = 'MiniIconsOrange' },
  },
})
-- mock nvim-web-devicons
require('mini.icons').mock_nvim_web_devicons()
