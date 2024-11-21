local utils = require('heirline.utils')
local _utils = require('user.configs.heirline.utils')

local mode = require('user.configs.heirline.components.statusline.mode')
local git_branch = require('user.configs.heirline.components.statusline.git-branch')
local git_modify = require('user.configs.heirline.components.statusline.git-modify')
local filename = require('user.configs.heirline.components.statusline.filename')
local diagnostics = require('user.configs.heirline.components.statusline.diagnostics')
local filetype = require('user.configs.heirline.components.statusline.filetype')
local cursor = require('user.configs.heirline.components.statusline.cursor')
local encoding = require('user.configs.heirline.components.statusline.encoding')
local time = require('user.configs.heirline.components.statusline.time')
local postion = require('user.configs.heirline.components.statusline.postion')

return {
  utils.insert({
    init = function(self)
      self.mode = vim.fn.mode(1)
      self.filename = vim.api.nvim_buf_get_name(0)
    end,
    hl = { bg = 'NONE' },
  }, mode, git_branch, filename, git_modify, _utils.align, diagnostics, cursor, filetype, encoding, postion, time),
}
