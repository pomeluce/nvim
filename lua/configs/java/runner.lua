local Runtime = require('configs.java.runtime')

local M = {}

local function buffer_client(bufnr) return vim.lsp.get_clients({ name = 'jdtls', bufnr = bufnr })[1] end

local function split_args(value)
  if type(value) == 'table' then return value end
  if type(value) ~= 'string' or value == '' then return {} end
  return require('dap.utils').splitstr(value)
end

function M.new(root_dir, runtimes, has_debug)
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

return M
