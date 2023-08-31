local util = require('lspconfig.util')

return {
  cmd = { 'taplo', 'lsp', 'stdio' },
  filetypes = { 'toml' },
  root_dir = function(fname)
    return util.root_pattern('*.toml')(fname) or util.find_git_ancestor(fname)
  end,
  single_file_support = true,
}
