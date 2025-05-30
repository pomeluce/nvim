local vue_ls_path = vim.fn.expand('$MASON/packages') .. '/vue-language-server'

local handle = io.popen('which vue-language-server')
if handle then
  local result = handle:read('*a')
  handle:close()
  if result and result ~= '' then
    vue_ls_path = result:gsub('/bin/vue%-language%-server', '/lib/node_modules/@vue/language-server'):gsub('\n', '')
  end
end

local typescript_plugin_path = vue_ls_path .. '/node_modules/@vue/language-server'

return {
  filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx', 'vue' },
  init_options = {
    hostInfo = 'neovim',
    plugins = {
      {
        name = '@vue/typescript-plugin',
        location = typescript_plugin_path,
        languages = { 'vue' },
      },
    },
  },
}
