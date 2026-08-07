local Runtime = require('configs.java.runtime')
local Runner = require('configs.java.runner')

local M = {}
local projects = {}
local dap_initialized = false

local function load_config(path)
  if vim.fn.filereadable(path) ~= 1 then return {} end
  local ok, config = pcall(dofile, path)
  if not ok then
    vim.notify(('Failed to load Java config %s:\n%s'):format(path, config), vim.log.levels.ERROR)
    return {}
  end
  if type(config) ~= 'table' then
    vim.notify('Java config must return a table: ' .. path, vim.log.levels.ERROR)
    return {}
  end
  return config
end

local function collect_bundles()
  local bundles = {}
  local debug_dir = os.getenv('VSC_JAVA_DEBUG')
  local test_dir = os.getenv('VSC_JAVA_TEST')
  local debug_bundles = debug_dir and vim.fn.glob(debug_dir .. '/server/com.microsoft.java.debug.plugin-*.jar', false, true) or {}
  local test_bundles = test_dir and vim.fn.glob(test_dir .. '/server/*.jar', false, true) or {}
  vim.list_extend(bundles, debug_bundles)
  vim.list_extend(bundles, test_bundles)
  return bundles, #debug_bundles > 0, #test_bundles > 0
end

local function java_cmd(root_dir)
  local cmd = { 'jdtls', '-data', vim.fn.stdpath('cache') .. '/jdtls/' .. vim.fn.sha256(root_dir):sub(1, 16) }
  local lombok = os.getenv('JAVA_LOMBOK')
  if lombok and vim.fn.filereadable(lombok) == 1 then table.insert(cmd, 2, '--jvm-arg=-javaagent:' .. lombok) end
  return cmd
end

local function project_client(root_dir)
  for _, client in ipairs(vim.lsp.get_clients({ name = 'jdtls' })) do
    if vim.fs.normalize(client.config.root_dir or '') == vim.fs.normalize(root_dir) then return client end
  end
end

local function status_handler(root_dir)
  local ready = false
  return function(err, result)
    if err then
      vim.notify('Java LSP status error: ' .. (err.message or vim.inspect(err)), vim.log.levels.ERROR)
      return
    end
    if not result then return end
    if result.type == 'ServiceReady' then
      if not ready then
        ready = true
        vim.notify('Java LSP ready: ' .. vim.fs.basename(root_dir), vim.log.levels.INFO)
      end
    elseif result.type == 'ERROR' then
      vim.notify(result.message or result.type, vim.log.levels.ERROR)
    end
  end
end

---@param root_dir string
function M.setup(root_dir)
  root_dir = vim.fs.normalize(root_dir)
  local cached = projects[root_dir]
  if cached then
    require('jdtls').start_or_attach(cached.config)
    return cached.api
  end

  local root_settings = require('settings')
  local lsp_settings = root_settings.lsp or {}
  local settings = lsp_settings.jdtls or {}
  local runtimes = Runtime.project_runtimes(root_dir, settings.runtimes or {})
  local bundles, has_debug, has_test = collect_bundles()
  local project = load_config(root_dir .. '/.nvim/jdtls.lua')
  local base = vim.deepcopy(vim.lsp.config.jdtls or {})
  local config = vim.tbl_deep_extend(
    'force',
    base,
    {
      cmd = java_cmd(root_dir),
      root_dir = root_dir,
      init_options = { bundles = bundles },
      settings = { java = { configuration = { maven = settings.maven or {} } } },
    },
    project,
    {
      settings = { java = { configuration = { runtimes = runtimes } } },
      handlers = { ['language/status'] = status_handler(root_dir) },
    }
  )

  if has_debug and not dap_initialized then
    require('jdtls').setup_dap({ hotcodereplace = 'auto' })
    dap_initialized = true
  end
  require('jdtls').start_or_attach(config)

  local api = {
    root_dir = root_dir,
    runner = Runner.new(root_dir, runtimes, has_debug),
    client = function() return project_client(root_dir) end,
    has_debug = has_debug,
    has_test = has_test,
  }
  projects[root_dir] = { config = config, api = api }
  return api
end

return M
