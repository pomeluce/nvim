vim.api.nvim_create_autocmd('BufEnter', {
  once = true,
  callback = function()
    PackUtils.load({ name = 'indent-blankline.nvim' }, function()
      local hooks = require('ibl.hooks')
      local palette = require('base16-colorscheme').colors
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, 'RainbowBlue', { default = true, fg = palette.base0D, ctermfg = 'Blue' })
        vim.api.nvim_set_hl(0, 'RainbowViolet', { default = true, fg = palette.base0F, ctermfg = 'Magenta' })
        vim.api.nvim_set_hl(0, 'RainbowRed', { default = true, fg = palette.base08, ctermfg = 'Red' })
        vim.api.nvim_set_hl(0, 'RainbowYellow', { default = true, fg = palette.base0A, ctermfg = 'Yellow' })
        vim.api.nvim_set_hl(0, 'RainbowGreen', { default = true, fg = palette.base0B, ctermfg = 'Green' })
        vim.api.nvim_set_hl(0, 'RainbowOrange', { default = true, fg = palette.base09, ctermfg = 'White' })
        vim.api.nvim_set_hl(0, 'RainbowCyan', { default = true, fg = palette.base0C, ctermfg = 'Cyan' })
      end)
      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
      local highlight = { 'RainbowBlue', 'RainbowViolet', 'RainbowRed', 'RainbowYellow', 'RainbowGreen', 'RainbowOrange', 'RainbowCyan' }
      require('ibl').setup({ indent = { char = '│' }, scope = { char = '│', highlight = highlight } })
    end)
  end,
})
