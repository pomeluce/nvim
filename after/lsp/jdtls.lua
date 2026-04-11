---@type vim.lsp.Config
return {
  settings = {
    java = {
      configuration = {
        runtimes = require('utils').settings('lsp.jdtls.runtimes') or {},
        maven = require('utils').settings('lsp.jdtls.maven') or {},
      },
    },
  },
}
