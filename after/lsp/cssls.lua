---@type vim.lsp.Config
return {
  filetypes = { 'css', 'scss', 'less' },
  workspace_required = false,
  settings = {
    css = { validate = true, lint = { unknownAtRules = 'ignore' } },
    scss = { validate = true, lint = { unknownAtRules = 'ignore' } },
    less = { validate = true, lint = { unknownAtRules = 'ignore' } },
  },
}
