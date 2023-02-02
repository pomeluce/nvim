-- lsp 列表
local servers = {
  "bashls",
  "clangd",
  "cmake",
  "cssls",
  "eslint",
  "html",
  "jsonls",
  "tsserver",
  "sumneko_lua",
  "marksman",
  "sqls",
  "tailwindcss",
  "volar",
}

-- mason 设置
local settings = {
  ui = {
    border = "rounded",
    -- 设置安装图标
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
  -- log 等级
  log_level = vim.log.levels.INFO,
  -- 最大并发安装数量
  max_concurrent_installers = 4,
}

-- 加载 mason
require("mason").setup(settings)
-- 加载 mason-lspconfig
require("mason-lspconfig").setup({
  -- 自动安装列表
  ensure_installed = servers,
  -- 自动安装
  automatic_installation = true,
})

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  vim.notify('lspconfig 没有找到')
  return
end

local opts = {}

for _, server in pairs(servers) do
  opts = {
    on_attach = require("user.lsp.handlers").on_attach,
    capabilities = require("user.lsp.handlers").capabilities,
  }

  server = vim.split(server, "@")[1]

  local require_ok, conf_opts = pcall(require, "user.lsp.config." .. server)
  if require_ok then
    opts = vim.tbl_deep_extend("force", conf_opts, opts)
  end

  lspconfig[server].setup(opts)
end
