local Runtime = require('configs.java.runtime')

local M = {}
local java_icon = ''

local function buffer_client(bufnr) return vim.lsp.get_clients({ name = 'jdtls', bufnr = bufnr })[1] end

local function split_args(value)
  if type(value) == 'table' then return value end
  if type(value) ~= 'string' or value == '' then return {} end
  return require('dap.utils').splitstr(value)
end

function M.new(root_dir, runtimes, has_debug)
  local runner = {
    runs = {},
    run_order = {},
    current = nil,
    log_win = nil,
    discovery_running = false,
    discovery_complete = false,
    discovery_waiters = {},
    log_buffer_attach = nil,
  }

  function runner:set_log_buffer_attach(callback)
    self.log_buffer_attach = callback
    for _, run in pairs(self.runs) do
      if vim.api.nvim_buf_is_valid(run.buf) then callback(run.buf) end
    end
  end

  function runner:update_winbar()
    if not self.log_win or not vim.api.nvim_win_is_valid(self.log_win) then return end

    local run_order = self:valid_run_order()
    local labels = {}
    local counts = {}
    for _, main_class in ipairs(run_order) do
      local label = main_class:match('([^.]+)$') or main_class
      labels[main_class] = label
      counts[label] = (counts[label] or 0) + 1
    end

    local tabs = {}
    for _, main_class in ipairs(run_order) do
      local run = self.runs[main_class]
      if run and vim.api.nvim_buf_is_valid(run.buf) then
        local label = labels[main_class]
        if counts[label] > 1 then label = main_class end
        label = label:gsub('%%', '%%%%')
        local highlight = run == self.current and '%#TabLineSel#' or '%#JavaRunnerTab#'
        tabs[#tabs + 1] = ('%s %s %s '):format(highlight, java_icon, label)
      end
    end
    vim.wo[self.log_win].winbar = table.concat(tabs, '%#WinBar# ') .. '%#WinBar#'
  end

  function runner:valid_run_order()
    self.run_order = vim.tbl_filter(function(main_class)
      local run = self.runs[main_class]
      if run and vim.api.nvim_buf_is_valid(run.buf) then return true end
      self.runs[main_class] = nil
      return false
    end, self.run_order)
    return self.run_order
  end

  function runner:switch_log(offset)
    local run_order = self:valid_run_order()
    if #run_order == 0 then return end

    local current_index
    for index, main_class in ipairs(run_order) do
      if self.runs[main_class] == self.current then
        current_index = index
        break
      end
    end
    local target_index = current_index and (current_index - 1 + offset) % #run_order + 1 or (offset < 0 and #run_order or 1)
    local target = self.runs[run_order[target_index]]
    if not target then return end
    self.current = target
    self:show(target.buf)
  end

  function runner:configurations()
    return vim.tbl_filter(function(config) return not config.cwd or vim.fs.normalize(config.cwd) == root_dir end, require('dap').configurations.java or {})
  end

  function runner:discover(bufnr, opts)
    if not has_debug then return end
    opts = opts or {}
    local callback = opts.on_ready
    local configurations = self:configurations()
    if self.discovery_complete and not opts.force then
      if callback then callback(configurations) end
      return
    end
    if callback then table.insert(self.discovery_waiters, callback) end
    if self.discovery_running then return end

    self.discovery_running = true
    vim.api.nvim_buf_call(bufnr, function()
      require('jdtls.dap').setup_dap_main_class_configs({
        verbose = opts.verbose,
        on_ready = function()
          self.discovery_running = false
          self.discovery_complete = true
          local waiters = self.discovery_waiters
          self.discovery_waiters = {}
          local discovered = self:configurations()
          for _, waiter in ipairs(waiters) do
            waiter(discovered)
          end
        end,
      })
    end)
  end

  function runner:warm_up(client_id)
    if not has_debug then return end
    vim.schedule(function()
      local client = vim.lsp.get_client_by_id(client_id)
      if not client then return end
      for bufnr in pairs(client.attached_buffers or {}) do
        local valid = vim.api.nvim_buf_is_valid(bufnr)
        local name = valid and vim.api.nvim_buf_get_name(bufnr) or ''
        if valid and vim.bo[bufnr].filetype == 'java' and not vim.startswith(name, 'jdt://') then
          self:discover(bufnr)
          return
        end
      end
    end)
  end

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
    self:update_winbar()
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
      if self.log_buffer_attach then self.log_buffer_attach(buf) end
      local channel = vim.api.nvim_open_term(buf, {
        on_input = function(_, _, _, data)
          if run.job_id then vim.fn.chansend(run.job_id, data) end
        end,
      })
      run.channel = channel
      self.runs[config.mainClass] = run
      self.run_order[#self.run_order + 1] = config.mainClass
    elseif run.job_id then
      vim.fn.jobstop(run.job_id)
    end

    local function start_process(matched_home, resolved_java)
      local default_home = Runtime.java_home(runtimes)
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
      local job_id
      job_id = vim.fn.jobstart(command, {
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
            if run.job_id == job_id then run.job_id = nil end
          end)
        end,
      })
      run.job_id = job_id
    end

    local declared_version = Runtime.buffer_version(bufnr)
    local declared_home = Runtime.java_home(runtimes, declared_version)
    if declared_version and declared_home then
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
        local home = Runtime.java_home(runtimes, compliance)
        if home then vim.notify(('Java %s runtime: %s'):format(compliance or 'default', home), vim.log.levels.INFO) end
        start_process(home)
      end)
    end, bufnr)
  end

  function runner:start()
    local bufnr = vim.api.nvim_get_current_buf()
    if not has_debug then
      vim.notify('VSC_JAVA_DEBUG is required to discover main classes', vim.log.levels.ERROR)
      return
    end
    local configurations = self:configurations()
    if #configurations == 0 then
      self:discover(bufnr, {
        verbose = true,
        force = true,
        on_ready = function(discovered)
          if #discovered > 0 then
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

  function runner:debug()
    local bufnr = vim.api.nvim_get_current_buf()
    if not has_debug then
      vim.notify('VSC_JAVA_DEBUG is not configured or contains no debug bundle', vim.log.levels.ERROR)
      return
    end

    local function continue(configurations)
      if #configurations > 0 then
        require('dap').continue()
      else
        vim.notify('No main class found', vim.log.levels.ERROR)
      end
    end
    local configurations = self:configurations()
    if #configurations > 0 then
      continue(configurations)
    else
      self:discover(bufnr, { verbose = true, force = true, on_ready = continue })
    end
  end

  return runner
end

return M
