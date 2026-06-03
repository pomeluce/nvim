vim.api.nvim_create_autocmd('FileType', {
  once = true,
  pattern = { 'html', 'javascriptreact', 'typescriptreact', 'vue' },
  callback = function()
    PackUtils.load(
      { name = 'nvim-ts-autotag' },
      function()
        require('nvim-ts-autotag').setup({
          opts = { enable_rename = true, enable_close = true, enable_close_on_slash = true },
        })
      end
    )
  end,
})
