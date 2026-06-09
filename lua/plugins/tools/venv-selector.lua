vim.api.nvim_create_autocmd('FileType', {
  once = true,
  pattern = 'python',
  callback = function()
    PackUtils.load({ name = 'venv-selector.nvim' }, function()
      require('venv-selector').setup({ settings = { options = { notify_user_on_venv_activation = true } } })
      vim.keymap.set('n', '<leader>fv', '<cmd>VenvSelect<cr>', { desc = 'Select python virtual environment' })
    end)
  end,
})
