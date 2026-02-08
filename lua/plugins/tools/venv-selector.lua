vim.pack.add({
  { src = 'https://github.com/linux-cultist/venv-selector.nvim' },
})

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('SetupVenvSelector', { clear = true }),
  pattern = 'python',
  once = true,
  callback = function()
    require('venv-selector').setup({ settings = { options = { notify_user_on_venv_activation = true } } })
    vim.keymap.set('n', '<leader>fv', '<cmd>VenvSelect<cr>', { desc = 'Select python virtual environment' })
  end,
})
