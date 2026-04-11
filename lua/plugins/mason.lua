---@type packman.SpecItem
return {
  'mason-org/mason.nvim',
  cmd = { 'Mason', 'MasonInstall', 'MasonUpdate' },
  dependencies = { 'williamboman/mason-lspconfig.nvim', 'jay-babu/mason-nvim-dap.nvim' },
  enabled = require('utils').settings('mason.enable') or false,
  config = function()
    require('mason').setup({
      ui = {
        -- 设置安装图标
        icons = { package_pending = ' ', package_installed = ' ', package_uninstalled = ' ' },
      },
      -- log 等级
      log_level = vim.log.levels.INFO,
      -- 最大并发安装数量
      max_concurrent_installers = 10,
    })
    -- 加载 mason-lspconfig
    require('mason-lspconfig').setup({
      -- 自动安装列表
      ensure_installed = {
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
        'tailwindcss',
        'taplo',
        'ts_ls',
        'vue_ls',
      },
      -- 自动安装
      automatic_installation = true,
    })
    -- 加载 mason-nvim-dap
    require('mason-nvim-dap').setup({
      ensure_installed = {},
      automatic_installation = true,
    })
  end,
}
