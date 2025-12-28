return {
  {
    'williamboman/mason.nvim',
    cmd = { 'Mason', 'MasonInstall', 'MasonUpdate' },
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
      'jay-babu/mason-nvim-dap.nvim',
    },
    config = function() require('configs.mason') end,
  },

  {
    'neovim/nvim-lspconfig',
    event = 'User FilePost',
    dependencies = {
      { 'folke/neoconf.nvim', opts = {} },
      { 'folke/neodev.nvim', opts = {} },
      {
        'nvimdev/lspsaga.nvim',
        opts = {
          ui = {
            -- 主题
            theme = 'round',
            -- 圆角边框
            border = require('akirc').ui.borderStyle,
            -- 是否使用 nvim-web-devicons
            devicon = true,
            -- 是否显示标题
            title = false,
            winblend = 0,
            -- 展开图标
            expand = '',
            -- 折叠图标
            collapse = '',
            -- 预览图标
            preview = '',
            -- 代码操作图标
            code_action = '󰌵',
            -- 操作修复图标
            actionfix = '',
            -- 诊断图标
            diagnostic = '󰃤',
            -- 实现图标
            imp_sign = '󰳛',
            -- 悬浮图标
            hover = ' ',
            kind = {},
          },
          -- 顶栏 winbar 设置
          symbol_in_winbar = {
            enable = false,
            separator = ' ',
            hide_keyword = true,
            show_file = true,
            folder_level = 2,
            respect_root = true,
            -- 展示颜色
            color_mode = true,
          },
          code_action = {
            num_shortcut = true,
            -- 不显示服务来源
            show_server_name = false,
            keys = {
              -- keymap
              quit = 'q',
              exec = '<tab>',
            },
          },
          rename = {
            keymap = {
              quit = 'q',
            },
          },
        },
      },
    },
    init = function()
      local x = vim.diagnostic.severity
      local akirc = require('akirc')
      vim.diagnostic.config({
        virtual_text = { prefix = '' },
        signs = { text = { [x.ERROR] = '󰅙', [x.WARN] = '', [x.INFO] = '󰋼', [x.HINT] = '󰌵' } },
        underline = true,
        float = { border = akirc.ui.borderStyle },
      })

      -- Default border style
      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
      ---@diagnostic disable-next-line: duplicate-set-field
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = akirc.ui.borderStyle
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
      end
    end,
    config = function() require('configs.lsp') end,
  },

  {
    'stevearc/aerial.nvim',
    event = 'VeryLazy',
    opts = {
      backends = { 'lsp', 'treesitter', 'markdown', 'asciidoc', 'man' },
      layout = { default_direction = 'float', width = 0.5, max_width = 0.8 },
      float = { border = require('akirc').ui.borderStyle, relative = 'win', height = 0.5, max_height = 0.9 },
      keymaps = { ['<esc>'] = 'actions.close' },
    },
  },
}
