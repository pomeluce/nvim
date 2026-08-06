local M = {}
local projects = {}
local dap_initialized = false
local definition_origins = {}

function M.set_definition_origin(tabpage, bufnr) definition_origins[tabpage] = bufnr end

function M.take_definition_origin(tabpage)
  local bufnr = definition_origins[tabpage]
  definition_origins[tabpage] = nil
  return bufnr
end

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

local function buffer_client(bufnr) return vim.lsp.get_clients({ name = 'jdtls', bufnr = bufnr })[1] end

local function split_args(value)
  if type(value) == 'table' then return value end
  if type(value) ~= 'string' or value == '' then return {} end
  return require('dap.utils').splitstr(value)
end

local function maven_java_version(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local pom = vim.fs.find('pom.xml', { path = vim.fs.dirname(filename), upward = true, type = 'file' })[1]
  if not pom then return end
  local file = io.open(pom, 'r')
  if not file then return end
  local content = file:read('*a')
  file:close()
  return content:match('<java%.version>%s*([^<%s]+)%s*</java%.version>')
    or content:match('<maven%.compiler%.release>%s*([^<%s]+)%s*</maven%.compiler%.release>')
    or content:match('<maven%.compiler%.source>%s*([^<%s]+)%s*</maven%.compiler%.source>')
    or content:match('<source>%s*([^<$%s][^<]*)%s*</source>')
    or content:match('<target>%s*([^<$%s][^<]*)%s*</target>')
end

local function maven_root_java_version(root_dir)
  local pom = root_dir .. '/pom.xml'
  if vim.fn.filereadable(pom) ~= 1 then return end
  local file = io.open(pom, 'r')
  if not file then return end
  local content = file:read('*a')
  file:close()
  return content:match('<java%.version>%s*([^<%s]+)%s*</java%.version>')
    or content:match('<maven%.compiler%.release>%s*([^<%s]+)%s*</maven%.compiler%.release>')
    or content:match('<maven%.compiler%.source>%s*([^<%s]+)%s*</maven%.compiler%.source>')
end

local function project_runtimes(root_dir, runtimes)
  local result = vim.deepcopy(runtimes)
  local version = maven_root_java_version(root_dir)
  if not version then return result end
  local aliases = { ['8'] = '1.8', ['1.8'] = '8' }
  local matched = false
  for _, runtime in ipairs(result) do
    local runtime_version = runtime.name:match('^JavaSE%-(.+)$')
    local selected = runtime_version == version or runtime_version == aliases[version]
    runtime.default = selected or nil
    matched = matched or selected
  end
  if not matched then vim.notify(('No JavaSE-%s runtime configured for %s'):format(version, root_dir), vim.log.levels.WARN) end
  return result
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

local function new_runner(root_dir, java_home)
  local runner = { runs = {}, current = nil, log_win = nil }

  function runner:show(buf)
    if self.log_win and vim.api.nvim_win_is_valid(self.log_win) then
      vim.api.nvim_win_set_buf(self.log_win, buf)
    else
      vim.cmd('botright 15split')
      self.log_win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(self.log_win, buf)
      vim.wo[self.log_win].number = false
      vim.wo[self.log_win].relativenumber = false
      vim.wo[self.log_win].signcolumn = 'no'
    end
  end

  function runner:toggle()
    if self.log_win and vim.api.nvim_win_is_valid(self.log_win) then
      vim.api.nvim_win_hide(self.log_win)
      self.log_win = nil
    elseif self.current then
      self:show(self.current.buf)
    end
  end

  function runner:stop()
    if self.current and self.current.job_id then vim.fn.jobstop(self.current.job_id) end
  end

  function runner:launch(config, bufnr)
    local run = self.runs[config.mainClass]
    if not run then
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, 'Java: ' .. config.mainClass)
      run = { buf = buf }
      local channel = vim.api.nvim_open_term(buf, {
        on_input = function(_, _, _, data)
          if run.job_id then vim.fn.chansend(run.job_id, data) end
        end,
      })
      run.channel = channel
      self.runs[config.mainClass] = run
    elseif run.job_id then
      vim.fn.jobstop(run.job_id)
    end

    local function start_process(matched_home, resolved_java)
      local default_home = java_home()
      local java = resolved_java or (matched_home and (matched_home .. '/bin/java')) or (default_home and (default_home .. '/bin/java')) or 'java'
      local command = { java }
      vim.list_extend(command, split_args(config.vmArgs))
      if config.classPaths and #config.classPaths > 0 then vim.list_extend(command, { '-cp', table.concat(config.classPaths, package.config:sub(1, 1) == '\\' and ';' or ':') }) end
      table.insert(command, config.mainClass)
      vim.list_extend(command, split_args(config.args))

      self.current = run
      self:show(run.buf)
      local channel = assert(run.channel)
      vim.fn.chansend(channel, table.concat(command, ' ') .. '\r\n')
      run.job_id = vim.fn.jobstart(command, {
        cwd = root_dir,
        pty = true,
        on_stdout = function(_, data)
          if data then vim.fn.chansend(channel, data) end
        end,
        on_stderr = function(_, data)
          if data then vim.fn.chansend(channel, data) end
        end,
        on_exit = function(_, code)
          vim.schedule(function()
            vim.fn.chansend(channel, ('\r\nProcess finished with exit code %d\r\n'):format(code))
            run.job_id = nil
          end)
        end,
      })
    end

    local declared_version = maven_java_version(bufnr)
    local declared_home = java_home(declared_version)
    if declared_home then
      vim.notify(('Java %s runtime: %s'):format(declared_version, declared_home), vim.log.levels.INFO)
      start_process(declared_home)
      return
    end

    local client = buffer_client(bufnr)
    if not client then
      vim.notify('No jdtls client attached; using the configured default JDK', vim.log.levels.WARN)
      return start_process()
    end
    local commands = (client.server_capabilities.executeCommandProvider or {}).commands or {}
    if config.projectName and vim.tbl_contains(commands, 'vscode.java.resolveJavaExecutable') then
      client:request('workspace/executeCommand', {
        command = 'vscode.java.resolveJavaExecutable',
        arguments = { config.mainClass, config.projectName },
      }, function(err, java_exec)
        if not err and type(java_exec) == 'string' and java_exec ~= '' then
          vim.schedule(function()
            vim.notify('Java runtime: ' .. java_exec, vim.log.levels.INFO)
            start_process(nil, java_exec)
          end)
          return
        end
        vim.schedule(function() vim.notify('jdtls could not resolve the main class JDK; trying project compliance', vim.log.levels.WARN) end)
        local fallback_config = vim.deepcopy(config)
        fallback_config.projectName = nil
        self:launch(fallback_config, bufnr)
      end, bufnr)
      return
    end
    client:request('workspace/executeCommand', {
      command = 'java.project.getSettings',
      arguments = { vim.uri_from_bufnr(bufnr), { 'org.eclipse.jdt.core.compiler.compliance' } },
    }, function(err, result)
      local compliance = result and result['org.eclipse.jdt.core.compiler.compliance']
      if err or not compliance then vim.notify('Could not resolve project Java version; using the configured fallback JDK', vim.log.levels.WARN) end
      vim.schedule(function()
        local home = java_home(compliance)
        if home then vim.notify(('Java %s runtime: %s'):format(compliance or 'default', home), vim.log.levels.INFO) end
        start_process(home)
      end)
    end, bufnr)
  end

  function runner:start()
    local bufnr = vim.api.nvim_get_current_buf()
    if not dap_initialized then
      vim.notify('VSC_JAVA_DEBUG is required to discover main classes', vim.log.levels.ERROR)
      return
    end
    local configurations = vim.tbl_filter(function(config) return not config.cwd or vim.fs.normalize(config.cwd) == root_dir end, require('dap').configurations.java or {})
    if #configurations == 0 then
      require('jdtls.dap').setup_dap_main_class_configs({
        verbose = true,
        on_ready = function(configs)
          if #configs > 0 then
            self:start()
          else
            vim.notify('No main class found', vim.log.levels.ERROR)
          end
        end,
      })
      return
    end
    if #configurations == 1 then
      self:launch(configurations[1], bufnr)
      return
    end
    vim.ui.select(configurations, {
      prompt = 'Select main class:',
      format_item = function(item) return item.name or item.mainClass end,
    }, function(item)
      if item then self:launch(item, bufnr) end
    end)
  end

  return runner
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
  local runtimes = project_runtimes(root_dir, settings.runtimes or {})
  local function java_home(compliance)
    if compliance then
      local version = tostring(compliance)
      local aliases = { ['8'] = '1.8', ['1.8'] = '8' }
      for _, runtime in ipairs(runtimes) do
        local runtime_version = runtime.name:match('^JavaSE%-(.+)$')
        if runtime_version == version or runtime_version == aliases[version] then return runtime.path end
      end
    end
    for _, runtime in ipairs(runtimes) do
      if runtime.default then return runtime.path end
    end
    return runtimes[1] and runtimes[1].path or nil
  end

  local bundles, has_debug, has_test = collect_bundles()
  local global = load_config(vim.fn.stdpath('config') .. '/after/lsp/jdtls.lua')
  local project = load_config(root_dir .. '/.nvim/jdtls.lua')
  local config = vim.tbl_deep_extend('force', {
    cmd = java_cmd(root_dir),
    root_dir = root_dir,
    init_options = { bundles = bundles },
    settings = { java = { configuration = { maven = settings.maven or {} } } },
  }, global, project)
  config.settings = config.settings or {}
  config.settings.java = config.settings.java or {}
  config.settings.java.configuration = config.settings.java.configuration or {}
  config.settings.java.configuration.runtimes = runtimes
  config.handlers = config.handlers or {}
  config.handlers['language/status'] = status_handler(root_dir)

  if has_debug and not dap_initialized then
    require('jdtls').setup_dap({ hotcodereplace = 'auto' })
    dap_initialized = true
  end
  require('jdtls').start_or_attach(config)

  local runner = new_runner(root_dir, java_home)
  local api = {
    root_dir = root_dir,
    runner = runner,
    client = function() return project_client(root_dir) end,
    has_debug = has_debug,
    has_test = has_test,
  }
  projects[root_dir] = { config = config, api = api }
  return api
end

return M
