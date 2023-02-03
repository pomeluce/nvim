return {
  -- 启用 volar 接管模式
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' },
  -- 初始化选项
  init_options = {
    typescript = {
      tsdk = '/usr/lib/node_modules/typescript/lib/',
    }
  }
}
