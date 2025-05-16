local M = {}

local akirc = require('akirc')

function M.DBUI()
  vim.cmd('exec "Dbee"')
end

function M.config()
  -- do nothing
  vim.cmd('com! CALLDB lua require("user.configs.dbee").DBUI()')
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
    window_layout = require('dbee.layouts').Default:new {
      call_log_height = 15,
      result_height = 15,
    },
  }
end

return M
