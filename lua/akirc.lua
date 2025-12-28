local M = {}

M.ui = {
  borderStyle = 'rounded',
}

M.hl = {
  winSeparator = { fg = '#676b6e' },
}

M.mason = {
  enable = false,
}

M.session = {
  ignore_dir = { '~/downloads', '~/Downloads' },
  projects = {
    '$DEVROOT/wsp/*',
    '$DEVROOT/code/web/*',
    '$DEVROOT/code/rust/*',
    '$DEVROOT/code/sql/*',
    '$DEVROOT/code/java/*',
    '$DEVROOT/code/cpp/*',
    '$DEVROOT/code/scripts/*',
  },
  lazy_load = function()
    local argv = vim.v.argv
    for _, arg in ipairs(argv) do
      if arg == '+CALLDB' then return true end
    end
    return false
  end,
}

M.file = {
  markdown = {
    browser = '',
  },
  run_cmd = {},
  search = {
    grep_args = {},
  },
  db_workspace = os.getenv('DEVROOT') .. '/code/sql/dadbod-queries',
}

return M
