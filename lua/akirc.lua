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
    '/wsp/akir-shell',
    '/wsp/akir-zimfw',
    '/wsp/nvim',
    '/wsp/nixos',
    '/wsp/dotfiles',
    '/wsp/code/web/*',
    '/wsp/code/rust/*',
    '/wsp/code/sql/*',
    '/wsp/code/java/*',
    '/wsp/code/cpp/*',
  },
}

M.file = {
  markdown = {
    browser = '',
  },
  run_cmd = {},
  search = {
    grep_args = {},
  },
}

return M
