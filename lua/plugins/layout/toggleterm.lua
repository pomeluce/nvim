---@type packman.SpecItem[]
return {
  {
    'akinsho/toggleterm.nvim',
    event = 'UIEnter',
    init = function() end,
    config = function()
      local opts = {
        direction = 'float',
        highlights = { FloatBorder = { link = 'FloatBorder' } },
        float_opts = { width = 100, height = 30, title_pos = 'center', border = 'rounded' },
      }
      if require('utils').is_win then opts.shell = 'pwsh.exe --noLog' end

      require('toggleterm').setup(opts)

      local term = require('configs.terminal')
      term.setToggleKey('<C-t>', 'TERM', '', nil)

      local map = vim.keymap.set
      map('n', '<leader>rf', term.runFile, { desc = 'Run current buffer file' })
      map('i', '<leader>rf', term.runFile, { desc = 'Run current buffer file' })
    end,
  },
}
