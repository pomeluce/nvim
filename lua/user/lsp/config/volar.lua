local function get_ts_server_path(root_dir)
  local util = require('lspconfig.util')

  local global_ts = '/usr/lib/node_modules/typescript/lib/tsserverlibrary.js'
  local found_ts = ''
  local function check_dir(path)
    found_ts = util.path.join(path, 'node_modules', 'typescript', 'lib')
    if util.path.exists(found_ts) then
      return path
    end
  end
  if util.search_ancestors(root_dir, check_dir) then
    return found_ts
  else
    return global_ts
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
