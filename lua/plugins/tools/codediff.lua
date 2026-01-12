vim.pack.add({
  { src = 'https://github.com/esmuellert/codediff.nvim' },
  { src = 'https://github.com/MunifTanjim/nui.nvim' },
}, { load = false })

vim.api.nvim_create_user_command('CodeDiff', function(opts)
  vim.pack.add({
    { src = 'https://github.com/esmuellert/codediff.nvim' },
    { src = 'https://github.com/MunifTanjim/nui.nvim' },
  })
  require('codediff').setup()
  vim.cmd({ cmd = 'CodeDiff', args = opts.fargs, bang = opts.bang })
end, { nargs = '*', bang = true, desc = 'Lazy-load codediff.nvim' })
