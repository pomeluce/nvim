vim.pack.add({
  { src = 'https://github.com/shellRaining/hlchunk.nvim' },
})

vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('SetupHLChunk', { clear = true }),
  callback = function()
    require('hlchunk').setup({
      chunk = {
        enable = true,
        style = { { fg = '#79AC78' }, { fg = '#c21f30' } },
        use_treesitter = false,
      },
      indent = {
        enable = true,
        -- 更多的字符可以在 https://unicodeplus.com/ 这个网站上找到
        chars = { '│' },
        style = { '#4C5257' },
      },
      line_num = { enable = true, use_treesitter = false, style = '#79AC78' },
      blank = { enable = false },
    })
  end,
})
