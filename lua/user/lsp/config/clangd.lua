return {
  cmd = { 'clangd', '--offset-encoding=utf-16' },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
  single_file_support = true,
  init_options = {
    -- clang 文件状态
    clangdFileStatus = true,
    -- 使用占位符
    usePlaceholders = true,
    -- 自动补全
    completeUnimported = true,
    -- 语义高亮
    semanticHighlighting = true,
  },
}
