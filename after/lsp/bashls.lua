---@type vim.lsp.Config
return {
  cmd = { 'bash-language-server', 'start' },
  settings = {
    bashIde = {
      -- 用于在工作区查找和解析 shell 脚本文件的 Glob 模式
      -- 在各文件的背景分析功能中使用
      -- 防止递归扫描,这会在打开文件时导致问题
      -- 默认上游模式是"**/*@(.sh|.inc|.bash|.command)"
      globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.zsh|.command)',
    },
  },
  filetypes = { 'sh', 'zsh' },
  single_file_support = true,
}
