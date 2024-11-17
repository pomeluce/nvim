local mason_registry = require('mason-registry')
local vue_language_server_path = mason_registry.get_package('vue-language-server'):get_install_path() .. '/node_modules/@vue/language-server'

return {
  filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx', 'vue' },
  init_options = {
    hostInfo = 'neovim',
    plugins = {
      {
        name = '@vue/typescript-plugin',
        location = vue_language_server_path,
        languages = { 'vue' },
      },
    },
  },
}
