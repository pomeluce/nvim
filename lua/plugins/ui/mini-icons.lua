local files = {}
local prettiers = { '.prettierrc', '.prettierrc.json', '.prettierrc.js', '.prettierrc.cjs', 'prettierrc', 'prettierrc.json', 'prettierrc.js', 'prettierrc.cjs' }
for _, name in ipairs(prettiers) do
  files[name] = { glyph = '', hl = 'MiniIconsBlue' }
end

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    PackUtils.load({ name = 'mini.icons' }, function()
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
    end)
  end,
})
