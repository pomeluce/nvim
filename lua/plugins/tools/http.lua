vim.g.rest_nvim = {
  ui = { keybinds = { prev = '<S-Tab>', next = '<Tab>' } },
}

vim.filetype.add({ extension = { rest = 'http' } })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'http',
  callback = function(event)
    if not PackUtils.load({ name = 'rest.nvim', deps = { 'nvim-nio', 'fidget.nvim', 'nvim-treesitter' } }) then return end

    local opts = { buffer = event.buf, desc = 'Send current request' }
    vim.keymap.set('n', '<C-CR>', '<Cmd>horizontal Rest run<CR>', opts)
    vim.keymap.set('n', '<leader>Rs', '<Cmd>horizontal Rest run<CR>', opts)
    vim.keymap.set('n', '<leader>Re', '<Cmd>Rest env select<CR>', { buffer = event.buf, desc = 'Select HTTP environment file' })
  end,
})
