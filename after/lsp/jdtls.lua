---@type vim.lsp.Config
return {
  settings = {
    java = {
      configuration = {
        runtimes = require('utils').settings('lsp.jtdls.runtimes'),
      },
    },
  },
}
