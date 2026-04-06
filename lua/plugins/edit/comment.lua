---@type packman.SpecItem[]
return {
  {
    'folke/ts-comments.nvim',
    event = 'VimEnter',
    config = function()
      local map = vim.keymap.set
      require('ts-comments').setup({})
      map('n', '<leader>/', 'gcc', { remap = true, desc = 'Toggle line comment' })
      map('v', '<leader>/', 'gc', { remap = true, desc = 'Toggle line comment' })
      map('n', '<leader><leader>/', 'gbc', { remap = true, desc = 'Toggle block comment' })
      map('v', '<leader><leader>/', 'gb', { remap = true, desc = 'Toggle block comment' })
    end,
  },
}
