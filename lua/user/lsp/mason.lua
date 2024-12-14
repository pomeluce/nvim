-- lsp 列表
local lsp_servers = {
  'bashls',
  'clangd',
  'cmake',
  'cssls',
  'emmet_language_server',
  'html',
  'jsonls',
  'kotlin_language_server',
  'lua_ls',
  'marksman',
  'rust_analyzer',
  'sqlls',
  'tailwindcss',
  'taplo',
  'ts_ls',
  'unocss',
  'volar',
}

-- dap 列表
local dap_servers = { 'js' }

-- formmater 列表
--[[ local formmater_servers = {
  'beautysh',
  'prettier',
  'rustfmt', -- should installed rustup
  'shfmt',
  'stylua',
} ]]

-- mason 设置
local settings = {
  ui = {
    -- 设置安装图标
    icons = {
      package_installed = '✓',
      package_pending = '➜',
      package_uninstalled = '✗',
    },
  },
  -- log 等级
  log_level = vim.log.levels.INFO,
  -- 最大并发安装数量
  max_concurrent_installers = 5,
}

-- 加载 mason
require('mason').setup(settings)
-- 加载 mason-lspconfig
require('mason-lspconfig').setup {
  -- 自动安装列表
  ensure_installed = lsp_servers,
  -- 自动安装
  automatic_installation = true,
}
-- 加载 mason-nvim-dap
require('mason-nvim-dap').setup {
  ensure_installed = dap_servers,
}

-- lsp 配置
for _, server in pairs(lsp_servers) do
  local opt = {
    on_attach = require('user.lsp.handlers').on_attach,
    capabilities = require('user.lsp.handlers').capabilities,
  }
  local result, config = pcall(require, 'user.lsp.config.' .. server)
  if result then
    require('lspconfig')[server].setup(vim.tbl_deep_extend('keep', opt, config))
  end
end
