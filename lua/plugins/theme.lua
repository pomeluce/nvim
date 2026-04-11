---@type packman.SpecItem[]
return {
  {
    'catppuccin/nvim',
    event = 'UIEnter',
    config = function()
      if require('utils').settings('theme.enable') or false then
        require('catppuccin').setup({
          flavour = 'auto',
          -- :h background
          background = { light = 'latte', dark = 'mocha' },
          transparent_background = true,
          float = { transparent = true },
          term_colors = true,
          integrations = {
            aerial = true,
            diffview = true,
            mini = { enabled = true, indentscope_color = 'sky' },
            noice = true,
            treesitter = true,
            notify = true,
            gitsigns = true,
            flash = true,
            blink_cmp = true,
            snacks = true,
          },
          highlight_overrides = {
            all = function(colors)
              return {
                winSeparator = { fg = colors.overlay2 },
                SnacksPickerPrompt = { fg = colors.peach },
                SnacksPickerDir = { fg = colors.overlay2 },
                SnacksTitle = { fg = colors.base, bg = colors.red },
                SnacksPickerToggle = { fg = colors.base, bg = colors.red },
                SnacksPickerTitle = { fg = colors.base, bg = colors.green },
                BlinkCmpLabel = { fg = colors.text, style = {} },
                BlinkCmpLabelMatch = { fg = colors.blue, style = { 'bold' } },
                BlinkCmpMenuSelection = { fg = colors.base, bg = colors.blue },
                AvanteSidebarWinSeparator = { fg = colors.surface1 },
                AvanteSidebarWinHorizontalSeparator = { fg = colors.surface1 },
              }
            end,
          },
          color_overrides = {
            frappe = {
              rosewater = '#ea6962',
              flamingo = '#ea6962',
              red = '#ea6962',
              maroon = '#ea6962',
              pink = '#d3869b',
              mauve = '#d3869b',
              peach = '#e78a4e',
              yellow = '#d8a657',
              green = '#a9b665',
              teal = '#89b482',
              sky = '#89b482',
              sapphire = '#89b482',
              blue = '#7daea3',
              lavender = '#7daea3',

              text = '#f5f5f5',
              subtext1 = '#ebebeb',
              subtext0 = '#e0e0e0',
              overlay2 = '#cccccc',
              overlay1 = '#b3b3b3',
              overlay0 = '#999999',
              surface2 = '#424242',
              surface1 = '#3d3d3d',
              surface0 = '#383838',
              base = '#202020',
              mantle = '#262626',
              crust = '#2b2b2b',
            },
            mocha = {
              rosewater = '#d3c6aa',
              flamingo = '#f07173',
              pink = '#d87595',
              mauve = '#d87595',
              red = '#f07173',
              maroon = '#63b4ed',
              peach = '#e69875',
              yellow = '#e2ae6a',
              green = '#99c983',
              teal = '#60a673',
              sky = '#78bdb4',
              sapphire = '#78bdb4',
              blue = '#78bdb4',
              lavender = '#9d94d4',

              text = '#f5f5f5',
              subtext1 = '#ebebeb',
              subtext0 = '#e0e0e0',
              overlay2 = '#cccccc',
              overlay1 = '#b3b3b3',
              overlay0 = '#999999',
              surface2 = '#424242',
              surface1 = '#3d3d3d',
              surface0 = '#383838',
              base = '#202020',
              mantle = '#262626',
              crust = '#2b2b2b',
            },
          },
        })

        vim.cmd('colorscheme catppuccin')
        vim.api.nvim_set_hl(0, 'StatusLine', { bg = 'none' })
      else
        --- @param name string
        --- @param val vim.api.keyset.highlight
        local set_hl = function(name, val) vim.api.nvim_set_hl(0, name, val) end

        local palette = require('mini.base16').config.palette

        set_hl('AvanteSidebarWinSeparator', { fg = palette.base04, bg = 'NONE' })
        set_hl('AvanteSidebarWinHorizontalSeparator', { fg = palette.base04, bg = 'NONE' })
        set_hl('BlinkCmpLabel', { fg = palette.base07, bold = false })
        set_hl('BlinkCmpLabelMatch', { fg = palette.base0D, bold = true })
        set_hl('BlinkCmpMenuSelection', { fg = palette.base00, bg = palette.base0D })
        set_hl('Comment', { fg = palette.base04 })
        set_hl('NonText', { fg = palette.base04 })
        set_hl('NvimTreeCursorLine', { link = 'CursorLine' })
        set_hl('NvimTreeFolderIcon', { fg = palette.base0D })
        set_hl('SnacksPickerPrompt', { fg = palette.base09 })
        set_hl('SnacksPickerDir', { fg = palette.base04 })
        set_hl('SnacksTitle', { fg = palette.base00, bg = palette.base08 })
        set_hl('SnacksPickerToggle', { fg = palette.base00, bg = palette.base08 })
        set_hl('SnacksPickerTitle', { fg = palette.base00, bg = palette.base0B })
        set_hl('WinBarNc', { fg = palette.base04, bg = 'NONE' })
        set_hl('WinSeparator', { fg = palette.base03, bg = 'NONE' })

        local groups = {
          'DiagnosticFloatingOk',
          'DiagnosticFloatingInfo',
          'DiagnosticFloatingWarn',
          'DiagnosticFloatingError',
          'DiagnosticFloatingHint',
          'Folded',
          'GitSignsAdd',
          'GitSignsChange',
          'GitSignsDelete',
          'GitSignsUntracked',
          'GitSignsStagedAdd',
          'GitSignsStagedChange',
          'GitSignsStagedDelete',
          'GitSignsStagedUntracked',
          'MiniFilesTitleFocused',
          'NormalFloat',
          'NormalNc',
          'Pmenu',
          'StatusLine',
          'TabLineFill',
          'WinBar',
        }
        for _, group in ipairs(groups) do
          local hl = vim.tbl_extend('force', vim.api.nvim_get_hl(0, { name = group, link = false }), { bg = 'NONE' })
          hl.default = hl.default == true and false or nil
          set_hl(group, hl)
        end
      end
    end,
  },
}
