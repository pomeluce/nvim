local M = {}

-- lsp 列表
M.lsp_servers = {
  'basedpyright',
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
  'vue_ls',
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
  return function()
    dofile(vim.g.base46_cache .. 'mason')

    local is_enable = require('akirc').mason.enable
    ---@diagnostic disable-next-line: redundant-parameter
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
      ensure_installed = is_enable and M.lsp_servers or {},
      -- 自动安装
      automatic_installation = is_enable,
    }
    -- 加载 mason-nvim-dap
    require('mason-nvim-dap').setup {
      ensure_installed = is_enable and M.dap_servers or {},
      automatic_installation = is_enable,
    }
  end
end

return M
