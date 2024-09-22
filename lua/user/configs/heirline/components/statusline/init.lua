local utils = require('heirline.utils')
local colors = require('user.configs.heirline.colors')
local _utils = require('user.configs.heirline.utils')

local mode = require('user.configs.heirline.components.statusline.mode')
local git = require('user.configs.heirline.components.statusline.git')
local filename = require('user.configs.heirline.components.statusline.filename')
local diagnostics = require('user.configs.heirline.components.statusline.diagnostics')
local lsp = require('user.configs.heirline.components.statusline.lsp')
local cursor = require('user.configs.heirline.components.statusline.cursor')
local encoding = require('user.configs.heirline.components.statusline.encoding')
local size = require('user.configs.heirline.components.statusline.size')
local cwd = require('user.configs.heirline.components.statusline.cwd')
local postion = require('user.configs.heirline.components.statusline.postion')

return {
  utils.insert({
    init = function(self)
      self.mode = vim.fn.mode(1)
      self.filename = vim.api.nvim_buf_get_name(0)
    end,
    hl = { bg = colors.statusline_bg },
  }, mode, git, filename, _utils.align, diagnostics, lsp, cursor, encoding, size, cwd, postion),
}
