vim.pack.add({
  { src = 'https://github.com/nvim-mini/mini.files' },
})

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  group = vim.api.nvim_create_augroup('SetupMini', { clear = true }),
  callback = function()
    _G.MiniFiles = require('mini.files')

    MiniFiles.setup({
      mappings = { close = '<ESC>', synchronize = 'S' },
      windows = { width_focus = 25, width_nofocus = 20 },
    })
    -- 打开 mini files 文件管理器
    require('utils').map('n', '<bs>', MiniFiles.open, { desc = 'Open mini file explorer' })
  end,
})
