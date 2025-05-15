local M = {}

local akirc = require('akirc')

function M.config()
  -- do nothing
end

function M.setup()
  return {
    float_options = {
      border = akirc.ui.borderStyle,
    },
    editor = {
      directory = akirc.file.db_workspace,
      window_options = {
        number = true,
        relativenumber = true,
      },
      mappings = {
        -- run what's currently selected on the active connection
        { key = '<c-cr>', mode = 'v', action = 'run_selection' },
        -- run the whole file on the active connection
        { key = '<c-cr>', mode = 'n', action = 'run_file' },
      },
    },
  }
end

return M
