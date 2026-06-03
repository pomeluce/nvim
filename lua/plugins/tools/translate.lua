vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    PackUtils.load(
      { name = 'translate.nvim' },
      function()
        require('translate').setup({
          default = { command = 'translate_shell' },
          preset = { command = { translate_shell = { args = { '-e', 'bing' } } } },
        })
      end
    )
  end,
})
