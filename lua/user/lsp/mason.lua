local M = {}

-- lsp 列表
M.lsp_servers = {
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
  'nil_ls',
  'rust_analyzer',
  'sqlls',
  'tailwindcss',
  'taplo',
  'ts_ls',
  'unocss',
  'volar',
}

-- dap 列表
M.dap_servers = { 'js' }

-- formmater 列表
--[[ local formmater_servers = {
  'beautysh',
  'nixfmt', -- custom install
  'prettier',
  'rustfmt', -- should installed rustup
  'shfmt',
  'stylua',
  'sqlfluff',
} ]]

-- mason 设置
M.setup = function()
  dofile(vim.g.base46_cache .. 'mason')

  require('mason').setup {
    ui = {
      -- 设置安装图标
      icons = {
        package_pending = ' ',
        package_installed = ' ',
        package_uninstalled = ' ',
      },
      border = require('akirc').ui.borderStyle,
    },
    -- log 等级
    log_level = vim.log.levels.INFO,
    -- 最大并发安装数量
    max_concurrent_installers = 10,
  }
  -- 加载 mason-lspconfig
  require('mason-lspconfig').setup {
    -- 自动安装列表
    ensure_installed = M.lsp_servers,
    -- 自动安装
    automatic_installation = true,
  }
  -- 加载 mason-nvim-dap
  require('mason-nvim-dap').setup {
    ensure_installed = M.dap_servers,
    automatic_installation = true,
  }
end

return M
