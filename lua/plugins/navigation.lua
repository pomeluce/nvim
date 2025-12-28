return {
  -- 快速跳转
  { 'folke/flash.nvim', event = 'VeryLazy', opts = { modes = { char = { enabled = false } } } },

  -- which-key
  {
    'folke/which-key.nvim',
    keys = { '<leader>', '"', "'", '`', 'c', 'v', 'g' },
    cmd = 'WhichKey',
    opts = function()
      dofile(vim.g.base46_cache .. 'whichkey')
      return { win = { border = require('akirc').ui.borderStyle, padding = { 1, 2, 1, 2 } }, layout = { width = { min = 20, max = 50 }, spacing = 3 } }
    end,
  },

  {
    'Bekaboo/dropbar.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
    opts = {
      menu = {
        preview = false,
        win_configs = { border = require('akirc').ui.borderStyle },
        scrollbar = { enable = true, background = false },
      },
    },
  },
}
