local files = {}
local prettiers = { '.prettierrc', '.prettierrc.json', '.prettierrc.js', '.prettierrc.cjs', 'prettierrc', 'prettierrc.json', 'prettierrc.js', 'prettierrc.cjs' }
for _, name in ipairs(prettiers) do
  files[name] = { glyph = '', hl = 'MiniIconsBlue' }
end

---@type packman.SpecItem[]
return {
  {
    'nvim-mini/mini.icons',
    config = function()
      require('mini.icons').setup({
        style = 'glyph',
        default = { file = { glyph = '󰈚', hl = 'MiniIconsGrey' } },
        file = vim.tbl_deep_extend('force', {
          README = { glyph = '󰂺', hl = 'MiniIconsYellow' },
          ['README.md'] = { glyph = '󰂺', hl = 'MiniIconsWhite' },
        }, files),
        filetype = {
          bash = { glyph = '󱆃', hl = 'MiniIconsGreen' },
          sh = { glyph = '󱆃', hl = 'MiniIconsGrey' },
          toml = { glyph = '󱄽', hl = 'MiniIconsOrange' },
        },
      })
      require('mini.icons').mock_nvim_web_devicons()
    end,
  },
}
