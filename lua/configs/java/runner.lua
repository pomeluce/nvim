local Launch = require('configs.java.launch')
local Prepare = require('configs.java.prepare')

local M = {}
local java_icon = ''

---@class JavaRunState
---@field buf integer
---@field main_class string
---@field project_name string
---@field channel? integer
---@field job_id? integer

---@class JavaLaunchTask
---@field mode 'run'|'debug'
---@field bufnr integer
---@field config? JavaLaunchTarget

---@param config JavaLaunchTarget
---@return string
local function run_key(config) return (config.projectName or '') .. '\0' .. config.mainClass end

---@param config JavaLaunchTarget
---@return string
local function display_name(config)
  local project = config.projectName or ''
  return project ~= '' and (project .. '/' .. config.mainClass) or config.mainClass
end

---@param err any
---@return string
local function error_message(err)
  if type(err) == 'table' then return err.message or vim.inspect(err) end
  return tostring(err)
end

function M.new(root_dir, runtimes, has_debug)
  local launch = Launch.new(root_dir)
  local preparation = Prepare.new(root_dir, runtimes)
  ---@class JavaRunner
  ---@field runs table<string, JavaRunState>
  ---@field run_order string[]
  ---@field current? JavaRunState
  ---@field log_win? integer
  ---@field log_buffer_attach? fun(bufnr: integer)
  ---@field launch_queue JavaLaunchTask[]
  ---@field launch_task? JavaLaunchTask
  local runner = {
    runs = {},
    run_order = {},
    current = nil,
    log_win = nil,
    log_buffer_attach = nil,
    launch_queue = {},
    launch_task = nil,
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
    for _, key in ipairs(run_order) do
      local run = self.runs[key]
      if run then
        local label = run.main_class:match('([^.]+)$') or run.main_class
        labels[key] = label
        counts[label] = (counts[label] or 0) + 1
      end
    end

    local tabs = {}
    for _, key in ipairs(run_order) do
      local run = self.runs[key]
      if run and vim.api.nvim_buf_is_valid(run.buf) then
        local label = labels[key]
        if counts[label] > 1 and run.project_name ~= '' then label = run.project_name .. '/' .. label end
        label = label:gsub('%%', '%%%%')
        local highlight = run == self.current and '%#TabLineSel#' or '%#JavaRunnerTab#'
        tabs[#tabs + 1] = ('%s %s %s '):format(highlight, java_icon, label)
      end
    end
    vim.wo[self.log_win].winbar = table.concat(tabs, '%#WinBar# ') .. '%#WinBar#'
  end

  function runner:valid_run_order()
    self.run_order = vim.tbl_filter(function(key)
      local run = self.runs[key]
      if run and vim.api.nvim_buf_is_valid(run.buf) then return true end
      self.runs[key] = nil
      return false
    end, self.run_order)
    return self.run_order
  end

  function runner:switch_log(offset)
    local run_order = self:valid_run_order()
    if #run_order == 0 then return end

    local current_index
    for index, key in ipairs(run_order) do
      if self.runs[key] == self.current then
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

  function runner:run(config)
    local key = run_key(config)
    local run = self.runs[key]
    if not run then
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, 'Java: ' .. display_name(config))
      run = {
        buf = buf,
        main_class = config.mainClass,
        project_name = config.projectName or '',
      }
      if self.log_buffer_attach then self.log_buffer_attach(buf) end
      local channel = vim.api.nvim_open_term(buf, {
        on_input = function(_, _, _, data)
          if run.job_id then vim.fn.chansend(run.job_id, data) end
        end,
      })
      run.channel = channel
      self.runs[key] = run
      self.run_order[#self.run_order + 1] = key
    elseif run.job_id then
      vim.fn.jobstop(run.job_id)
    end

    local vm_args, env = launch:resolve(config)
    local command = { config.javaExec }
    vim.list_extend(command, Launch.split_args(vm_args))
    if config.classPaths and #config.classPaths > 0 then vim.list_extend(command, { '-cp', table.concat(config.classPaths, package.config:sub(1, 1) == '\\' and ';' or ':') }) end
    table.insert(command, config.mainClass)
    vim.list_extend(command, Launch.split_args(config.args))

    self.current = run
    self:show(run.buf)
    local channel = assert(run.channel)
    vim.fn.chansend(channel, table.concat(command, ' ') .. '\r\n')
    local job_id
    job_id = vim.fn.jobstart(command, {
      cwd = root_dir,
      env = env,
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

  function runner:debug_config(config)
    local debug_config = vim.deepcopy(config)
    debug_config.vmArgs, debug_config.env = launch:resolve(debug_config)
    require('dap').run(debug_config)
  end

  function runner:finish_task(task)
    if self.launch_task ~= task then return end
    self.launch_task = nil
    vim.schedule(function() self:process_queue() end)
  end

  function runner:prepare_task(task, config)
    if self.launch_task ~= task then return end
    preparation:prepare(config, task.bufnr, function(err, prepared)
      if self.launch_task ~= task then return end
      if err then
        if err.kind ~= 'cancelled' then vim.notify(error_message(err), vim.log.levels.ERROR, { title = 'Java' }) end
      elseif task.mode == 'debug' then
        self:debug_config(prepared)
      else
        self:run(prepared)
      end
      self:finish_task(task)
    end)
  end

  function runner:select_target(task, configurations)
    if self.launch_task ~= task then return end
    if #configurations == 0 then
      vim.notify('No main class found', vim.log.levels.ERROR)
      self:finish_task(task)
    elseif #configurations == 1 then
      self:prepare_task(task, configurations[1])
    else
      vim.ui.select(configurations, {
        prompt = task.mode == 'debug' and 'Select main class to debug:' or 'Select main class:',
        format_item = function(item) return item.name or item.mainClass end,
      }, function(item)
        if self.launch_task ~= task then return end
        if item then
          self:prepare_task(task, item)
        else
          self:finish_task(task)
        end
      end)
    end
  end

  function runner:process_queue()
    if self.launch_task or #self.launch_queue == 0 then return end
    local task = table.remove(self.launch_queue, 1)
    self.launch_task = task
    if task.config then
      self:prepare_task(task, task.config)
      return
    end
    preparation:discover(task.bufnr, function(err, configurations)
      if self.launch_task ~= task then return end
      if err then
        if err.kind ~= 'cancelled' then vim.notify(error_message(err), vim.log.levels.ERROR, { title = 'Java' }) end
        self:finish_task(task)
        return
      end
      self:select_target(task, configurations)
    end)
  end

  function runner:enqueue(mode, bufnr, config)
    self.launch_queue[#self.launch_queue + 1] = { mode = mode, bufnr = bufnr, config = config }
    self:process_queue()
  end

  function runner:launch(config, bufnr) self:enqueue('run', bufnr, config) end

  function runner:start()
    if not has_debug then
      vim.notify('VSC_JAVA_DEBUG is required to discover main classes', vim.log.levels.ERROR)
      return
    end
    self:enqueue('run', vim.api.nvim_get_current_buf())
  end

  function runner:debug()
    if not has_debug then
      vim.notify('VSC_JAVA_DEBUG is not configured or contains no debug bundle', vim.log.levels.ERROR)
      return
    end
    self:enqueue('debug', vim.api.nvim_get_current_buf())
  end

  function runner:stop()
    self.launch_queue = {}
    self.launch_task = nil
    preparation:cancel()
    if self.current and self.current.job_id then vim.fn.jobstop(self.current.job_id) end
  end

  return runner
end

return M
