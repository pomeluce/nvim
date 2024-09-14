local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  local utils = require('heirline.utils')
  local colors = require('user.configs.heirline.colors')

  local mode = require('user.configs.heirline.modules.mode')
  local git = require('user.configs.heirline.modules.git')
  local filename = require('user.configs.heirline.modules.filename')
  local align = require('user.configs.heirline.modules.align')
  local progress = require('user.configs.heirline.modules.progress')
  local diagnostics = require('user.configs.heirline.modules.diagnostics')
  local lsp = require('user.configs.heirline.modules.lsp')
  local cursor = require('user.configs.heirline.modules.cursor')
  local encoding = require('user.configs.heirline.modules.encoding')
  local size = require('user.configs.heirline.modules.size')
  local cwd = require('user.configs.heirline.modules.cwd')
  local postion = require('user.configs.heirline.modules.postion')
  return {
    statusline = {
      utils.insert({
        init = function(self)
          self.mode = vim.fn.mode(1)
          self.filename = vim.api.nvim_buf_get_name(0)
        end,
        hl = { bg = colors.statusline_bg },
      }, mode, git, filename, align, progress, diagnostics, lsp, cursor, encoding, size, cwd, postion),
    },

    opts = {
      colors = {
        diag_warn = utils.get_highlight('DiagnosticWarn').fg,
        diag_error = utils.get_highlight('DiagnosticError').fg,
        diag_hint = utils.get_highlight('DiagnosticHint').fg,
        diag_info = utils.get_highlight('DiagnosticInfo').fg,
      },
    },
  }
end

return M
