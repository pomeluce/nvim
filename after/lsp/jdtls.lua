---@type vim.lsp.Config
return {
  settings = {
    java = {
      configuration = {
        runtimes = require('settings').lsp.jdtls.runtimes,
        maven = require('settings').lsp.jdtls.maven,
      },
    },
  },
}
