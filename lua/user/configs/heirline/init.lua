local M = {}

function M.config()
  vim.o.showtabline = 3
  vim.o.laststatus = 3
end

function M.setup()
  local utils = require('heirline.utils')

  local StatusLine = require('user.configs.heirline.components.statusline')
  local Bufferline = require('user.configs.heirline.components.bufferline')

  return {
    statusline = StatusLine,

    tabline = Bufferline,

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
