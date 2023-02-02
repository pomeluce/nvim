return {
  -- 启用 volar 接管模式
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' },
  -- 初始化选项
  init_options = {
    config = {
      javascript = {
        format = {
          enable = true
        }
      },
      typescript = {
        format = {
          enable = true
        }
      }
    },
    preferences = {
      includeCompletionsForModuleExports = true,
      includeCompletionsWithInsertText = true,
      includeAutomaticOptionalChainCompletions = true,
      includeCompletionsWithSnippetText = true,
      showDeprecated = true,
      showReferences = true,
      showUnused = true,
      completion = {
        autoImport = true,
        tagCasing = 'both',
        useSuggestionPriority = true
      }
    }
  }
}
