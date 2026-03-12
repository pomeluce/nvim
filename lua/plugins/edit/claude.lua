vim.pack.add({
  { src = 'https://github.com/coder/claudecode.nvim' },
})

local map = vim.keymap.set

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('SetupClaude', { clear = true }),
  callback = function()
    require('claudecode').setup({
      terminal_cmd = vim.fn.exepath('claude'),
    })
    -- Claude
    map('n', '<leader>ac', '<cmd>ClaudeCode<cr>', { desc = 'Toggle Claude' })
    map('n', '<leader>af', '<cmd>ClaudeCodeFocus<cr>', { desc = 'Focus Claude' })
    map('n', '<leader>ar', '<cmd>ClaudeCode --resume<cr>', { desc = 'Resume Claude' })
    map('n', '<leader>aC', '<cmd>ClaudeCode --continue<cr>', { desc = 'Continue Claude' })
    map('n', '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', { desc = 'Select Claude model' })
    map('n', '<leader>aq', '<cmd>ClaudeCodeClose<cr>', { desc = 'Close Claude' })
    -- Buffer / File
    map('n', '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', { desc = 'Add current buffer' })
    -- Visual send
    map('v', '<leader>as', '<cmd>ClaudeCodeSend<cr>', { desc = 'Send to Claude' })
    -- Diff management
    map('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', { desc = 'Accept diff' })
    map('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', { desc = 'Deny diff' })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw' },
  callback = function() map('n', '<leader>as', '<cmd>ClaudeCodeTreeAdd<cr>', { desc = 'Add file', buffer = true }) end,
})
