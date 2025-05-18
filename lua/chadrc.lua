local akirc = require('akirc')
-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = 'onedark',
  transparency = true,

  hl_override = {
    CmpBorder = { link = 'FloatBorder' },
    CmpDocBorder = { link = 'FloatBorder' },
    TelescopeBorder = { link = 'FloatBorder' },
    TelescopePromptBorder = { link = 'FloatBorder' },
    WinSeparator = akirc.hl.winSeparator,
    NvimTreeWinSeparator = akirc.hl.winSeparator,
    ['@comment'] = { fg = '#868e96', italic = true },
  },
}

M.ui = {}

M.nvdash = {
  load_on_startup = true,
  header = {
    '   █████╗   ██╗  ██╗  ██╗  ██████╗   ',
    '  ██╔══██╗  ██║ ██╔╝  ██║  ██╔══██╗  ',
    '  ███████║  █████╔╝   ██║  ██████╔╝  ',
    '  ██╔══██║  ██╔═██╗   ██║  ██╔══██╗  ',
    '  ██║  ██║  ██║  ██╗  ██║  ██║  ██║  ',
    '  ╚═╝  ╚═╝  ╚═╝  ╚═╝  ╚═╝  ╚═╝  ╚═╝  ',
    '                                     ',
    '       [  akirvim v2025.3.1 ]       ',
    '                                     ',
    '                                     ',
  },
  buttons = {
    { txt = ' Project List', keys = 'l', cmd = 'Telescope neovim-project discover theme=dropdown' },
    { txt = ' Recently Opend Project', keys = 'p', cmd = 'Telescope neovim-project history theme=dropdown' },
    { txt = ' Recently Opend Files', keys = 'h', cmd = 'Telescope oldfiles' },
    { txt = ' Find Files', keys = 'f', cmd = 'Telescope find_files' },
    { txt = ' Keymap Setting', keys = 'm', cmd = 'NvCheatsheet' },

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

M.term = {
  float = {
    border = akirc.ui.borderStyle,
  },
}
M.lsp = { signature = false }

return M
