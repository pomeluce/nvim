return {
  cmd = { 'taplo', 'lsp', 'stdio' },
  filetypes = { 'toml' },
  root_dir = require('user.core.funcutil').root_pattern('*.toml'),
  single_file_support = true,
}
