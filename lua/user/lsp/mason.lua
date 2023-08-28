-- lsp 列表
local lsp_servers = {
  'bashls',
  'clangd',
  'cmake',
  'cssls',
  'html',
  'jsonls',
  'kotlin_language_server',
  'lua_ls',
  'marksman',
  'rust_analyzer',
  'sqlls',
  'tailwindcss',
  'tsserver',
  'volar',
}

-- dap 列表
local dap_servers = { 'js', }

-- formmater 列表
--[[ local formmater_servers = {
  'stylua',
  'prettierd'
} ]]

-- mason 设置
local settings = {
  ui = {
    border = 'rounded',
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
  -- lsp 配置
  handlers = {
    function(server_name)
      local opt = {}
      local result, conf = pcall(require, 'user.lsp.config.' .. server_name)
      if result then
        opt = vim.tbl_deep_extend('force', conf, opt);
      end
      require('lspconfig')[server_name].setup({
        settings = opt,
        on_attach = require('user.lsp.handlers').on_attach,
        capabilities = require('user.lsp.handlers').capabilities,
      })
    end,
  },
}
-- 加载 mason-nvim-dap
require('mason-nvim-dap').setup({
  ensure_installed = dap_servers,
})
