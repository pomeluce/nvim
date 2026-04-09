---@type vim.lsp.Config
return {
  settings = {
    java = {
      configuration = {
        runtimes = require('utils').settings('lsp.jdtls.runtimes'),
        maven = require('utils').settings('lsp.jdtls.maven'),
      },
    },
  },
}
