local M = {}
local _cache -- 首次调用缓存 config + api, 后续 buffer 只做 start_or_attach

---@param root_dir string Java 项目根目录
function M.setup(root_dir)
  if _cache then
    require('jdtls').start_or_attach(_cache.config)
    return _cache.api
  end
  -- java-debug bundles ($VSC_JAVA_DEBUG)
  local bundles = {}
  local vsc_java_debug = os.getenv('VSC_JAVA_DEBUG')
  if vsc_java_debug then
    bundles = vim.fn.glob(vsc_java_debug .. '/server/com.microsoft.java.debug.plugin-*.jar', false, true)
  else
    vim.notify_once('$VSC_JAVA_DEBUG not set, DAP disabled', vim.log.levels.WARN)
  end

  -- vscode-java-test bundles ($VSC_JAVA_TEST)
  local vsc_java_test = os.getenv('VSC_JAVA_TEST')
  if vsc_java_test then
    local test_jars = vim.fn.glob(vsc_java_test .. '/server/*.jar', false, true)
    if #test_jars > 0 then vim.list_extend(bundles, test_jars) end
  else
    vim.notify_once('$VSC_JAVA_TEST not set, test support disabled', vim.log.levels.WARN)
  end

  -- Lombok ($JAVA_LOMBOK)
  local lombok_jar = os.getenv('JAVA_LOMBOK') or ''

  -- jdtls 启动命令
  local jdtls_cmd = { 'jdtls' }
  if lombok_jar ~= '' then
    jdtls_cmd = { 'env', 'JAVA_TOOL_OPTIONS=-javaagent:' .. lombok_jar, 'jdtls' }
  else
    vim.notify_once('$JAVA_LOMBOK not set, Lombok support disabled', vim.log.levels.WARN)
  end

  -- 全局 LSP 配置 (after/lsp/jdtls.lua)
  local global_config = {}
  local lsp_path = vim.fn.stdpath('config') .. '/after/lsp/jdtls.lua'
  if vim.fn.filereadable(lsp_path) == 1 then
    local ok, cfg = pcall(dofile, lsp_path)
    if ok then global_config = cfg end
  end

  -- 项目级配置 (.nvim/jdtls.lua)
  local project_path = root_dir .. '/.nvim/jdtls.lua'
  local project_config = {}
  if vim.fn.filereadable(project_path) == 1 then
    local ok, cfg = pcall(dofile, project_path)
    if ok then project_config = cfg end
  end

  -- DAP 适配器 + main class 解析(仅执行一次, 不再由 on_attach 触发)
  require('jdtls').setup_dap({ hotcodereplace = 'auto' })
  vim.defer_fn(function() require('jdtls.dap').setup_dap_main_class_configs() end, 5000)
  local function on_attach() end

  -- jdtls config + start
  local config = vim.tbl_deep_extend('force', {
    cmd = jdtls_cmd,
    root_dir = root_dir,
    init_options = { bundles = bundles },
    settings = { java = { configuration = { runtimes = {}, maven = {} } } },
    on_attach = on_attach,
  }, global_config, project_config)

  require('jdtls').start_or_attach(config)

  -- java_home: runtimes default(runner:launch 优先用 jdtls 的 cfg.javaExec)
  local function java_home()
    local runtimes = require('settings').lsp.jdtls.runtimes or {}
    for _, rt in ipairs(runtimes) do
      if rt.default then return rt.path end
    end
    return runtimes[1] and runtimes[1].path or nil
  end

  -- JavaRunner
  local runner = { runs = {}, curr_run = nil, log_win = -1 }

  function runner:launch(cfg)
    local jh = java_home()
    local java_bin = cfg.javaExec or (jh and (jh .. '/bin/java')) or 'java'
    local cmd_str = java_bin
    if cfg.classPaths and #cfg.classPaths > 0 then cmd_str = cmd_str .. ' -cp ' .. table.concat(cfg.classPaths, ':') end
    if cfg.vmArgs and cfg.vmArgs ~= '' then cmd_str = cmd_str .. ' ' .. cfg.vmArgs end
    cmd_str = cmd_str .. ' ' .. cfg.mainClass
    if cfg.args and cfg.args ~= '' then cmd_str = cmd_str .. ' ' .. cfg.args end
    local run = self.runs[cfg.mainClass]
    if run then
      if run.is_running then run:stop() end
    else
      run = { buf = vim.api.nvim_create_buf(false, true), term_chan = nil, job_id = nil, is_running = false }
      vim.api.nvim_buf_set_name(run.buf, 'Java: ' .. cfg.mainClass)
      run.term_chan = vim.api.nvim_open_term(run.buf, {
        on_input = function(_, _, _, data)
          if run.job_id then vim.fn.chansend(run.job_id, data) end
        end,
      })
      self.runs[cfg.mainClass] = run
    end
    self.curr_run = run
    self:show_log(run.buf)
    vim.fn.chansend(run.term_chan, cmd_str .. '\r\n')
    run.is_running = true
    run.job_id = vim.fn.jobstart(cmd_str, {
      pty = true,
      on_stdout = function(_, data)
        if data then vim.fn.chansend(run.term_chan, data) end
      end,
      on_stderr = function(_, data)
        if data then vim.fn.chansend(run.term_chan, data) end
      end,
      on_exit = function(_, code)
        vim.schedule(function()
          vim.fn.chansend(run.term_chan, string.format('\r\nProcess finished with exit code: %d\r\n', code))
          run.is_running = false
          run.job_id = nil
        end)
      end,
    })
  end

  function runner:start()
    local dap = require('dap')
    local cfgs = dap.configurations.java or {}
    if #cfgs == 0 then
      require('jdtls.dap').setup_dap_main_class_configs({ verbose = true })
      vim.defer_fn(function()
        local c = dap.configurations.java or {}
        if #c > 0 then
          self:start()
        else
          vim.notify('No main class found', vim.log.levels.ERROR)
        end
      end, 3000)
      return
    end
    local items = {}
    for _, c in ipairs(cfgs) do
      table.insert(items, { name = c.name or c.mainClass, cfg = c })
    end
    local function pick(i)
      if i then self:launch(i.cfg) end
    end
    if #items == 1 then
      pick(items[1])
    else
      vim.ui.select(items, { prompt = 'Select main class:', format_item = function(v) return v.name end }, function(item)
        if item then pick(item) end
      end)
    end
  end

  function runner:show_log(buf)
    if self.log_win and vim.api.nvim_win_is_valid(self.log_win) then
      vim.api.nvim_win_set_buf(self.log_win, buf)
    else
      vim.cmd('sp | winc J | res 15 | buffer ' .. (buf or ''))
      self.log_win = vim.api.nvim_get_current_win()
      vim.wo[self.log_win].number = false
      vim.wo[self.log_win].relativenumber = false
      vim.wo[self.log_win].signcolumn = 'no'
    end
    vim.cmd('wincmd k')
  end

  function runner:toggle_log()
    if self.log_win and vim.api.nvim_win_is_valid(self.log_win) then
      vim.api.nvim_win_hide(self.log_win)
    elseif self.curr_run then
      self:show_log(self.curr_run.buf)
    end
  end

  function runner:stop()
    if self.curr_run and self.curr_run.is_running then
      vim.fn.jobstop(self.curr_run.job_id)
      vim.fn.jobwait({ self.curr_run.job_id }, 1000)
      self.curr_run.is_running = false
      self.curr_run.job_id = nil
    end
  end

  -- 用户命令
  local jdtls_mod = require('jdtls')
  local function create_cmd(name, fn, opts)
    pcall(vim.api.nvim_del_user_command, name)
    vim.api.nvim_create_user_command(name, fn, opts or {})
  end
  create_cmd('JavaRunMain', function() runner:start() end, { desc = 'Run Java main class' })
  create_cmd('JavaStopMain', function() runner:stop() end, { desc = 'Stop running Java main class' })
  create_cmd('JavaToggleLogs', function() runner:toggle_log() end, { desc = 'Toggle Java run log window' })
  create_cmd('JavaCompile', function()
    -- 传自定义 on_compile_result, 阻止 nvim-jdtls 默认的 copen(源码 L904)
    jdtls_mod.compile('full', function()
      vim.schedule(function()
        vim.cmd('copen')
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[buf].buftype == 'quickfix' then vim.bo[buf].buflisted = false end
        end
      end)
    end)
  end, { desc = 'Build Java workspace' })
  create_cmd('JavaUpdateConfig', function() jdtls_mod.update_project_config() end, { desc = 'Update jdtls project config' })
  create_cmd('JavaDebugMain', function()
    local dap = require('dap')
    if not dap.configurations.java or #dap.configurations.java == 0 then
      require('jdtls').dap.setup_dap_main_class_configs({ verbose = true })
      vim.defer_fn(function()
        if dap.configurations.java and #dap.configurations.java > 0 then
          dap.continue()
        else
          vim.notify('No main class found', vim.log.levels.ERROR)
        end
      end, 2000)
    else
      dap.continue()
    end
  end, { desc = 'Debug Java main class' })
  create_cmd('JavaTestClass', function() jdtls_mod.test_class() end, { desc = 'Run Java test class' })
  create_cmd('JavaTestMethod', function() jdtls_mod.test_nearest_method() end, { desc = 'Run Java test method' })
  local api = { jdtls = jdtls_mod, runner = runner, java_home = java_home, root_dir = root_dir }
  _cache = { config = config, api = api }
  return api
end

return M
