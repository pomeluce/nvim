local M = {}

function M.config()
  require('lspconfig').clangd.setup({
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
  })
end

return M
