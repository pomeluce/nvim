---@type vim.lsp.Config
return {
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
  workspace_required = false, -- 单文件支持
  init_options = {
    clangdFileStatus = true, -- clang 文件状态
    usePlaceholders = true, -- 使用占位符
    completeUnimported = true, -- 自动补全
    semanticHighlighting = true, -- 语义高亮
  },
}
