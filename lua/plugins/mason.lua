vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  once = true,
  callback = function()
    PackUtils.load({
      name = 'mason.nvim',
      deps = { 'mason-lspconfig.nvim', 'mason-nvim-dap.nvim' },
    }, function()
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
        ensure_installed = require('configs.lsp-servers').mason_servers(),
        -- 自动安装
        automatic_installation = true,
      })
      -- 加载 mason-nvim-dap
      require('mason-nvim-dap').setup({
        ensure_installed = {},
        automatic_installation = true,
      })
    end)
  end,
})
