vim.pack.add({
  { src = 'https://github.com/folke/ts-comments.nvim' },
})

-- 快捷键配置
local map = vim.keymap.set

-- 行注释
map('n', '<leader>/', 'gcc', { remap = true, desc = 'Toggle line comment' })
map('v', '<leader>/', 'gc', { remap = true, desc = 'Toggle line comment' })

-- 块注释
map('n', '<leader><leader>/', 'gbc', { remap = true, desc = 'Toggle block comment' })
map('v', '<leader><leader>/', 'gb', { remap = true, desc = 'Toggle block comment' })