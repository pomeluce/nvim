---@type vim.lsp.Config
return {
  settings = {
    basedpyright = {
      analysis = {
        ignorePatterns = { '*.pyi' },
        diagnosticSeverityOverrides = {
          reportCallIssue = 'warning',
          reportUnreachable = 'warning',
          reportUnusedImport = 'none',
          reportUnusedCoroutine = 'warning',
        },
        -- diagnosticMode = "workspace",
        diagnosticMode = 'openFilesOnly',
        typeCheckingMode = 'basic',
        reportCallIssue = 'none',
        disableOrganizeImports = true,
      },
    },
  },
}
