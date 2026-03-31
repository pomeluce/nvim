vim.pack.add({
  { src = 'https://github.com/nickjvandyke/opencode.nvim' },
})

local map = vim.keymap.set

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('SetupOpencode', { clear = true }),
  callback = function()
    map({ 'n', 'x' }, '<leader>oa', function() require('opencode').ask() end, { desc = 'Ask opencode…' })
    map({ 'n', 'x' }, '<leader>ol', function() require('opencode').select() end, { desc = 'Execute opencode action…' })
    map({ 'n', 't' }, '<leader>oc', function() require('opencode').toggle() end, { desc = 'Toggle opencode' })
    map({ 'n', 'x' }, '<leader>os', function() return require('opencode').operator('@this ') end, { desc = 'Add range to opencode', expr = true })
    map('n', '<leader>os', function() return require('opencode').operator('@this ') .. '_' end, { desc = 'Add line to opencode', expr = true })
  end,
})
