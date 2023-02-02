-- 是否成功加载 lspconfig
local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

-- 加载 mason
require 'user.lsp.mason'
-- 加载 lsp handlers
require 'user.lsp.handlers'.setup()
-- 加载 lsp null-ls
require 'user.lsp.null-ls'
