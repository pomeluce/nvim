vim.pack.add({
  { src = 'https://github.com/folke/ts-comments.nvim' },
})

local map = vim.keymap.set

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('SetupComment', { clear = true }),
  callback = function()
    require('ts-comments').setup({})
    -- 行注释
    map('n', '<leader>/', 'gcc', { remap = true, desc = 'Toggle line comment' })
    map('v', '<leader>/', 'gc', { remap = true, desc = 'Toggle line comment' })

    -- 块注释
    map('n', '<leader><leader>/', 'gbc', { remap = true, desc = 'Toggle block comment' })
    map('v', '<leader><leader>/', 'gb', { remap = true, desc = 'Toggle block comment' })
  end,
})
