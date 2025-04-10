-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = 'onedark',
  transparency = true,

  -- hl_override = {
  --     Comment = { italic = true },
  --     ["@comment"] = { italic = true },
  -- },
}

M.nvdash = {
  load_on_startup = true,
  header = {
    '   █████╗ ██╗  ██╗██╗██████╗   ',
    '  ██╔══██╗██║ ██╔╝██║██╔══██╗  ',
    '  ███████║█████╔╝ ██║██████╔╝  ',
    '  ██╔══██║██╔═██╗ ██║██╔══██╗  ',
    '  ██║  ██║██║  ██╗██║██║  ██║  ',
    '  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝  ',
    '                               ',
    '     [ akirvim v2025.1.3 ]     ',
    '                               ',
    '                               ',
  },
  buttons = {
    { txt = ' Project List', keys = 'l', cmd = 'Telescope neovim-project discover theme=dropdown' },
    { txt = ' Recently Opend Project', keys = 'p', cmd = 'Telescope neovim-project history theme=dropdown' },
    { txt = ' Recently Opend Files', keys = 'h', cmd = 'Telescope oldfiles' },
    { txt = ' Find Files', keys = 'f', cmd = 'Telescope find_files' },
    { txt = ' Keymap Setting', keys = 'm', cmd = 'edit $HOME/.config/nvim/lua/user/core/keymaps.lua' },

    { txt = ' ', hl = 'NvDashFooter', no_gap = true, rep = true },

    {
      txt = function()
        local stats = require('lazy').stats()
        local ms = math.floor(stats.startuptime) .. ' ms'
        return '  Loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms
      end,
      hl = 'NvDashFooter',
      no_gap = true,
    },

    { txt = ' ', hl = 'NvDashFooter', no_gap = true, rep = true },
  },
}

-- M.ui = {
--  tabufline = {
--     lazyload = false
-- }
-- }

return M
