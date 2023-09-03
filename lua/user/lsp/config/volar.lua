local function get_ts_server_path(root_dir)
  local util = require('lspconfig.util')
  local project_root = util.find_node_modules_ancestor(root_dir)

  local local_tsserverlib = project_root ~= nil and util.path.join(project_root, 'node_modules', 'typescript', 'lib', 'tsserverlibrary.js')
  local global_tsserverlib = '/usr/lib/node_modules/typescript/lib/tsserverlibrary.js'

  if local_tsserverlib and util.path.exists(local_tsserverlib) then
    return local_tsserverlib
  else
    return global_tsserverlib
  end
end

return {
  cmd = { 'vue-language-server', '--stdio' },
  -- 启用 volar 接管模式
  filetypes = { 'vue' },
  -- 初始化选项
  init_options = {
    typescript = {
      tsdk = '/usr/lib/node_modules/typescript/lib/',
    },
  },
  on_new_config = function(new_config, new_root_dir)
    new_config.init_options.typescript.serverPath = get_ts_server_path(new_root_dir)
  end,
}
