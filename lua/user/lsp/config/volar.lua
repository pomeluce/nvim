return {
  cmd = { 'vue-language-server', '--stdio' },
  -- 启用 volar 接管模式
  filetypes = { 'vue' },
  -- 初始化选项
  init_options = {
    typescript = {
      tsdk = '/usr/lib/node_modules/typescript/lib/',
    },
    vue = {
      hybridMode = false,
    },
  },
}
