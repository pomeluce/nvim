dofile(vim.g.base46_cache .. 'mason')

local is_enable = require('akirc').mason.enable
local servers = require('configs.servers')
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
  ensure_installed = is_enable and servers.lsp or {},
  -- 自动安装
  automatic_installation = is_enable,
}
-- 加载 mason-nvim-dap
require('mason-nvim-dap').setup {
  ensure_installed = is_enable and servers.dap or {},
  automatic_installation = is_enable,
}
