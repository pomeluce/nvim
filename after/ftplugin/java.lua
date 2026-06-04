if vim.b.load_java_plugin then return end
vim.b.load_java_plugin = true

local map = vim.keymap.set
PackUtils.load({ name = 'nvim-java', deps = { 'spring-boot.nvim' } }, function()
  require('java').setup({ jdk = { auto_install = false } })
  map('n', '<leader>jr', '<cmd>JavaRunnerRunMain<cr>', { desc = 'Run Java Main Class' })
  map('n', '<leader>js', '<cmd>JavaRunnerStopMain<cr>', { desc = 'Stop Java Main Class' })
  map('n', '<leader>jl', '<cmd>JavaRunnerToggleLogs<cr>', { desc = 'Toggle Java Logs' })
end)
