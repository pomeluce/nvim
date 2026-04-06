---@type packman.SpecItem[]
return {
  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'BufEnter',
    main = 'ibl',
    config = function()
      local hooks = require('ibl.hooks')
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, 'RainbowBlue', { default = true, fg = '#61AFEF', ctermfg = 'Blue' })
        vim.api.nvim_set_hl(0, 'RainbowViolet', { default = true, fg = '#C678DD', ctermfg = 'Magenta' })
        vim.api.nvim_set_hl(0, 'RainbowRed', { default = true, fg = '#E06C75', ctermfg = 'Red' })
        vim.api.nvim_set_hl(0, 'RainbowYellow', { default = true, fg = '#E5C07B', ctermfg = 'Yellow' })
        vim.api.nvim_set_hl(0, 'RainbowGreen', { default = true, fg = '#98C379', ctermfg = 'Green' })
        vim.api.nvim_set_hl(0, 'RainbowOrange', { default = true, fg = '#D19A66', ctermfg = 'White' })
        vim.api.nvim_set_hl(0, 'RainbowCyan', { default = true, fg = '#56B6C2', ctermfg = 'Cyan' })
      end)
      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
      local highlight = { 'RainbowBlue', 'RainbowViolet', 'RainbowRed', 'RainbowYellow', 'RainbowGreen', 'RainbowOrange', 'RainbowCyan' }
      require('ibl').setup({ indent = { char = '│' }, scope = { char = '│', highlight = highlight } })
    end,
  },
}
