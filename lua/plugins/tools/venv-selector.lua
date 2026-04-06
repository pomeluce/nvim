---@type packman.SpecItem[]
return {
  {
    'linux-cultist/venv-selector.nvim',
    ft = 'python',
    config = function()
      require('venv-selector').setup({ settings = { options = { notify_user_on_venv_activation = true } } })
      vim.keymap.set('n', '<leader>fv', '<cmd>VenvSelect<cr>', { desc = 'Select python virtual environment' })
    end,
  },
}
