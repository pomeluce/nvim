vim.pack.add({
  { src = 'https://github.com/windwp/nvim-ts-autotag' },
})

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('SetupAutoTag', { clear = true }),
  pattern = { 'html', 'javascriptreact', 'typescriptreact', 'vue' },
  callback = function()
    require('nvim-ts-autotag').setup({
      opts = { enable_rename = true, enable_close = true, enable_close_on_slash = true },
    })
  end,
})
