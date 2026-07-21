vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    PackUtils.load({ name = 'claudecode.nvim' }, function()
      local map = vim.keymap.set

      require('claudecode').setup({ terminal_cmd = vim.fn.exepath('claude'), terminal = { split_width_percentage = 0.40 } })
      map('n', '<leader>ac', '<cmd>ClaudeCode<cr>', { desc = 'Toggle Claude' })
      map('n', '<leader>af', '<cmd>ClaudeCodeFocus<cr>', { desc = 'Focus Claude' })
      map('n', '<leader>ar', '<cmd>ClaudeCode --resume<cr>', { desc = 'Resume Claude' })
      map('n', '<leader>aC', '<cmd>ClaudeCode --continue<cr>', { desc = 'Continue Claude' })
      map('n', '<leader>aq', '<cmd>ClaudeCodeClose<cr>', { desc = 'Close Claude' })
      map('n', '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', { desc = 'Add current buffer' })
      map('v', '<leader>as', '<cmd>ClaudeCodeSend<cr>', { desc = 'Send to Claude' })
      map('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', { desc = 'Accept diff' })
      map('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', { desc = 'Deny diff' })

      -- 文件树中添加文件的快捷键
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw' },
        callback = function() map('n', '<leader>as', '<cmd>ClaudeCodeTreeAdd<cr>', { desc = 'Add file', buffer = true }) end,
      })
    end)
  end,
})
