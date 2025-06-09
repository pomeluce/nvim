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
  ignore_dir = { '~/Downloads' },
  projects = {
    '$DEVROOT/wsp/akir-shell',
    '$DEVROOT/wsp/akir-zimfw',
    '$DEVROOT/wsp/nvim',
    '$DEVROOT/wsp/nixos',
    '$DEVROOT/wsp/dotfiles',
    '$DEVROOT/wsp/code/web/*',
    '$DEVROOT/wsp/code/rust/*',
    '$DEVROOT/wsp/code/sql/*',
    '$DEVROOT/wsp/code/java/*',
    '$DEVROOT/wsp/code/cpp/*',
  },
  lazy_load = function()
    local argv = vim.v.argv
    for _, arg in ipairs(argv) do
      if arg == '+CALLDB' then
        return true
      end
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
  db_workspace = '$DEVROOT/wsp/code/sql',
}

return M
