local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return {
    menu = {
      preview = false,
      win_configs = {
        border = require('akirc').ui.borderStyle,
      },
      scrollbar = {
        enable = true,
        background = false,
      },
    },
  }
end

return M
