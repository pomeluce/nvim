vim.pack.add({
  { src = 'https://github.com/lukas-reineke/indent-blankline.nvim' },
  -- { src = 'https://github.com/TheGLander/indent-rainbowline.nvim' },
  { src = 'https://github.com/HiPhish/rainbow-delimiters.nvim' },
})

vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('SetupIndentLine', { clear = true }),
  callback = function()
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
    vim.g.rainbow_delimiters = { query = { javascript = 'rainbow-parens', tsx = 'rainbow-parens', html = 'rainbow-parens' }, highlight = highlight }
  end,
})
