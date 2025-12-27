return {
  {
    'nvim-tree/nvim-tree.lua',
    cmd = { 'NvimTreeToggle', 'NvimTreeFindFileToggle', 'NvimTreeOpen', 'NvimTreeFocus' },
    init = function()
      vim.g.nvim_tree_firsttime = 1
      vim.cmd('hi! NvimTreeCursorLine cterm=NONE ctermbg=238')
      vim.cmd('hi! link NvimTreeFolderIcon NvimTreeFolderName')
    end,
    opts = function()
      return require('configs.nvimtree')
    end,
  },

  {
    'antosha417/nvim-lsp-file-operations',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-tree.lua' },
    opts = {},
  },

  {
    'akinsho/toggleterm.nvim',
    event = 'VeryLazy',
    init = function()
      local term = require('configs.terminal')
      term.setToggleKey('<C-t>', 'TERM', '', nil)
      term.setToggleKey('<C-b>', 'DBUI', 'nvim +CALLDB', { width = 130, height = 38 })
      term.setToggleKey('<C-p>', 'RANGER', 'ranger', nil)
    end,
    opts = function()
      local opts = {
        direction = 'float',
        highlights = { FloatBorder = { link = 'FloatBorder' } },
        float_opts = {
          border = require('akirc').ui.borderStyle,
          width = 120,
          height = 35,
          title_pos = 'center',
        },
      }

      if require('utils').is_windows then
        opts.shell = 'pwsh.exe --noLog'
      end

      return opts
    end,
  },

  -- 全局文件搜索
  {
    'nvim-telescope/telescope.nvim',
    lazy = false,
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-media-files.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      -- camelcase 命名转换
      { 'johmsalas/text-case.nvim' },
    },
    config = function()
      require('configs.telescope')
    end,
  },

  -- window picker 快速切换窗口
  {
    's1n7ax/nvim-window-picker',
    name = 'window-picker',
    event = 'VeryLazy',
    version = '2.*',
    opts = {
      filter_rules = { include_current_win = true, bo = { filetype = { 'fidget', 'NvimTree' } } },
      prompt_message = 'Pick window: ',
      highlights = {
        statusline = { focused = { fg = '#ededed', bg = '#e35e4f', bold = true }, unfocused = { fg = '#ededed', bg = '#3b5bdb', bold = true } },
        winbar = { focused = { fg = '#ededed', bg = '#e35e4f', bold = true }, unfocused = { fg = '#ededed', bg = '#3b5bdb', bold = true } },
      },
    },
  },
}
