local Launch = require('configs.java.launch')
local Prepare = require('configs.java.prepare')
local Picker = require('configs.java.picker')

local M = {}
local java_icon = ''
local close_text = '  '
local click_runners = setmetatable({}, { __mode = 'v' })

_G.JavaRunnerLogClick = function(id, _, button)
  if button ~= 'l' then return end
  local buf = math.floor(id / 2)
  vim.schedule(function()
    local runner = click_runners[buf]
    if not runner then return end
    for _, run in pairs(runner.runs) do
      if run.buf == buf then
        if id % 2 == 1 then
          runner:close_log(run)
        else
          runner:select_log(run)
        end
        return
      end
    end
  end)
end

local function truncate(text, width)
  if width <= 0 then return '' end
  if vim.fn.strdisplaywidth(text) <= width then return text end
  local ellipsis = vim.fn.strdisplaywidth('…') <= width and '…' or '.'
  local budget = width - vim.fn.strdisplaywidth(ellipsis)
  local shortened = ''
  for length = 1, vim.fn.strchars(text) do
    local candidate = vim.fn.strcharpart(text, 0, length)
    if vim.fn.strdisplaywidth(candidate) > budget then break end
    shortened = candidate
  end
  return shortened .. ellipsis
end

local function tab_text(tab, width)
  local prefix = ' ' .. java_icon .. ' '
  local label_width = width - vim.fn.strdisplaywidth(prefix .. close_text)
  if label_width < 1 then return truncate(tab.name, width) end
  return prefix .. truncate(tab.name, label_width) .. close_text
end

---@class JavaRunState
---@field buf integer
---@field main_class string
---@field project_name string
---@field channel? integer
---@field job_id? integer
---@field args? string[]
---@field hidden? boolean
---@field stopping? boolean
---@field request? JavaLaunchTask

---@class JavaLaunchTask
---@field mode 'run'|'debug'
---@field bufnr integer
---@field config? JavaLaunchTarget
---@field with_args? boolean
---@field batch? table
---@field request? JavaLaunchTask

---@param config JavaLaunchTarget
---@return string
local function run_key(config) return vim.json.encode({ config.projectName or '', config.mainClass, Launch.split_args(config.args) }) end

---@param config {mainClass: string, projectName?: string, args?: string|string[]}
---@return string
local function display_name(config)
  local project = config.projectName or ''
  local label = project ~= '' and (project .. '/' .. config.mainClass) or config.mainClass
  local args = Launch.format_args(Launch.split_args(config.args))
  return args ~= '' and (label .. ' ' .. args) or label
end

---@param config {mainClass: string, projectName?: string, args?: string|string[]}
---@param status? string
---@param hidden? boolean
---@return JavaPickerDescription
local function picker_description(config, status, hidden)
  return {
    name = config.mainClass:match('([^.]+)$') or config.mainClass,
    package_name = config.mainClass:match('^(.*)%.'),
    project = config.projectName,
    args = Launch.format_args(Launch.split_args(config.args)),
    status = status,
    hidden = hidden,
  }
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
    local tabs = {}
    local active = 1
    for _, key in ipairs(run_order) do
      local run = self.runs[key]
      if run and vim.api.nvim_buf_is_valid(run.buf) then
        local label = run.main_class:match('([^.]+)$') or run.main_class
        local text = (' %s %s%s'):format(java_icon, label, close_text)
        tabs[#tabs + 1] = { buf = run.buf, name = label, text = text, width = vim.fn.strdisplaywidth(text) }
        click_runners[run.buf] = self
        if run == self.current then active = #tabs end
      end
    end
    if #tabs == 0 then
      vim.wo[self.log_win].winbar = ''
      return
    end

    local width = vim.api.nvim_win_get_width(self.log_win)
    local left_marker, right_marker = '‹ ', ' ›'
    local left_width, right_width = vim.fn.strdisplaywidth(left_marker), vim.fn.strdisplaywidth(right_marker)
    -- In very narrow windows, give the current Main priority over overflow markers.
    local indicators = width >= left_width + right_width + vim.fn.strdisplaywidth(' ' .. java_icon .. ' … ')
    local function indicator_width(left, right) return indicators and ((left > 1 and left_width or 0) + (right < #tabs and right_width or 0)) or 0 end

    local left, right = active, active
    local budget = width - indicator_width(left, right)
    if tabs[active].width > budget then
      tabs[active].text = tab_text(tabs[active], budget)
      tabs[active].width = vim.fn.strdisplaywidth(tabs[active].text)
    end
    local total = tabs[active].width
    while true do
      local added = false
      if right < #tabs and total + 1 + tabs[right + 1].width + indicator_width(left, right + 1) <= width then
        right = right + 1
        total = total + 1 + tabs[right].width
        added = true
      end
      if left > 1 and total + 1 + tabs[left - 1].width + indicator_width(left - 1, right) <= width then
        left = left - 1
        total = total + 1 + tabs[left].width
        added = true
      end
      if not added then break end
    end

    local parts = {}
    if indicators and left > 1 then parts[#parts + 1] = '%#WinBar#' .. left_marker end
    for index = left, right do
      if index > left then parts[#parts + 1] = '%#WinBar# ' end
      local highlight = index == active and '%#TabLineSel#' or '%#JavaRunnerTab#'
      local tab = tabs[index]
      local has_close = tab.text:sub(-#close_text) == close_text
      local body = has_close and tab.text:sub(1, -#close_text - 1) or tab.text
      parts[#parts + 1] = highlight .. ('%%%d@v:lua.JavaRunnerLogClick@'):format(tab.buf * 2) .. body:gsub('%%', '%%%%') .. '%X'
      if has_close then parts[#parts + 1] = ('%%%d@v:lua.JavaRunnerLogClick@'):format(tab.buf * 2 + 1) .. close_text .. '%X' end
    end
    if indicators and right < #tabs then parts[#parts + 1] = '%#WinBar#' .. right_marker end
    vim.wo[self.log_win].winbar = table.concat(parts) .. '%#WinBar#'
  end

  function runner:valid_run_order()
    self.run_order = vim.tbl_filter(function(key)
      local run = self.runs[key]
      if run and (vim.api.nvim_buf_is_valid(run.buf) or run.job_id) then return true end
      self.runs[key] = nil
      return false
    end, self.run_order)
    return vim.tbl_filter(function(key)
      local run = self.runs[key]
      return not run.hidden and vim.api.nvim_buf_is_valid(run.buf)
    end, self.run_order)
  end

  function runner:select_log(run)
    self:ensure_log(run)
    run.hidden = false
    self.current = run
    self:show(run.buf)
  end

  function runner:close_log(run)
    run = run or self.current
    if not run then return end
    local order = self:valid_run_order()
    local index = 1
    for i, key in ipairs(order) do
      if self.runs[key] == run then
        index = i
        break
      end
    end
    run.hidden = true
    if self.current == run then
      self.current = nil
      local remaining = self:valid_run_order()
      local next_run = self.runs[remaining[math.min(index, #remaining)]]
      if next_run then
        self:select_log(next_run)
      elseif self.log_win and vim.api.nvim_win_is_valid(self.log_win) then
        vim.api.nvim_win_hide(self.log_win)
        self.log_win = nil
      end
    end
    if not run.job_id then
      for key, candidate in pairs(self.runs) do
        if candidate == run then self.runs[key] = nil end
      end
      click_runners[run.buf] = nil
      if vim.api.nvim_buf_is_valid(run.buf) then vim.api.nvim_buf_delete(run.buf, { force = true }) end
    end
    self:valid_run_order()
    self:update_winbar()
  end

  function runner:open_log()
    local items = {}
    self:valid_run_order()
    for _, key in ipairs(self.run_order) do
      items[#items + 1] = self.runs[key]
    end
    if #items == 0 then
      vim.notify('No Java logs available', vim.log.levels.INFO)
      return
    end
    Picker.select(items, {
      prompt = 'Java Logs',
      describe_item = function(run)
        return picker_description(
          { mainClass = run.main_class, projectName = run.project_name, args = run.args },
          run.job_id and (run.stopping and 'stopping' or 'running') or 'exited',
          run.hidden
        )
      end,
      format_item = function(run)
        local label = display_name({ mainClass = run.main_class, projectName = run.project_name, args = run.args })
        return label .. (run.job_id and ' [running]' or ' [exited]') .. (run.hidden and ' [hidden]' or '')
      end,
    }, function(selected)
      if selected and selected[1] then
        for _, run in pairs(self.runs) do
          if run == selected[1] then
            self:select_log(run)
            return
          end
        end
      end
    end)
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
      local resize_autocmd = vim.api.nvim_create_autocmd({ 'WinResized', 'VimResized' }, {
        callback = function() self:update_winbar() end,
      })
      vim.api.nvim_create_autocmd('WinClosed', {
        pattern = tostring(self.log_win),
        once = true,
        callback = function() vim.api.nvim_del_autocmd(resize_autocmd) end,
      })
    end
    self:update_winbar()
  end

  function runner:toggle()
    if self.log_win and vim.api.nvim_win_is_valid(self.log_win) then
      vim.api.nvim_win_hide(self.log_win)
      self.log_win = nil
    else
      local order = self:valid_run_order()
      if self.current and not self.current.hidden and vim.api.nvim_buf_is_valid(self.current.buf) then
        self:show(self.current.buf)
      elseif #order > 0 then
        self:select_log(self.runs[order[1]])
      else
        self:open_log()
      end
    end
  end

  function runner:ensure_log(run)
    if not run.channel or not vim.api.nvim_buf_is_valid(run.buf) then
      local buf = vim.api.nvim_buf_is_valid(run.buf) and run.buf or vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, ('java-log://%d/%s'):format(buf, run.main_class:match('([^.]+)$') or run.main_class))
      run.buf = buf
      if self.log_buffer_attach then self.log_buffer_attach(buf) end
      run.channel = vim.api.nvim_open_term(buf, {
        on_input = function(_, _, _, data)
          if run.job_id and not run.stopping then vim.fn.chansend(run.job_id, data) end
        end,
      })
      click_runners[buf] = self
      vim.api.nvim_create_autocmd('BufWipeout', {
        buffer = buf,
        once = true,
        callback = function()
          click_runners[buf] = nil
          run.hidden = true
        end,
      })
    end
  end

  local function write_output(run, data)
    if run.channel and vim.api.nvim_buf_is_valid(run.buf) then pcall(vim.fn.chansend, run.channel, data) end
  end

  function runner:run(config, task)
    config = vim.deepcopy(config)
    config.args = launch:arguments(config)
    local key = run_key(config)
    local run = self.runs[key]
    if run and run.job_id then return 'skipped' end
    local vm_args, env = launch:resolve(config)
    local command = { config.javaExec }
    vim.list_extend(command, Launch.split_args(vm_args))
    if config.classPaths and #config.classPaths > 0 then vim.list_extend(command, { '-cp', table.concat(config.classPaths, package.config:sub(1, 1) == '\\' and ';' or ':') }) end
    table.insert(command, config.mainClass)
    vim.list_extend(command, config.args)

    if not run then
      run = { buf = vim.api.nvim_create_buf(false, true), main_class = config.mainClass, project_name = config.projectName or '', args = config.args }
      self.runs[key] = run
      self.run_order[#self.run_order + 1] = key
    end
    run.request = task and (task.request or task) or nil
    run.stopping = false
    self:select_log(run)
    write_output(run, Launch.format_args(command) .. '\r\n')
    local job_id
    job_id = vim.fn.jobstart(command, {
      cwd = config.cwd or root_dir,
      env = env,
      pty = true,
      on_stdout = function(_, data)
        if data and run.job_id == job_id then write_output(run, data) end
      end,
      on_stderr = function(_, data)
        if data and run.job_id == job_id then write_output(run, data) end
      end,
      on_exit = function(_, code)
        vim.schedule(function()
          if run.job_id ~= job_id then return end
          write_output(run, ('\r\nProcess finished with exit code %d\r\n'):format(code))
          run.job_id = nil
          run.stopping = false
          self:update_winbar()
        end)
      end,
    })
    if job_id <= 0 then
      write_output(run, '\r\nFailed to start Java process\r\n')
      error('Failed to start Java process: ' .. display_name(config))
    end
    run.job_id = job_id
    return 'started'
  end

  function runner:debug_config(config)
    local debug_config = vim.deepcopy(config)
    debug_config.args = launch:arguments(debug_config)
    debug_config.vmArgs, debug_config.env = launch:resolve(debug_config)
    require('dap').run(debug_config)
    return 'started'
  end

  function runner:settle_task(task, result)
    if task.settled then return end
    task.settled = true
    local batch = task.batch
    if not batch then return end
    batch[result] = (batch[result] or 0) + 1
    batch.remaining = batch.remaining - 1
    if batch.remaining == 0 then
      vim.notify(
        ('Java launches: %d started, %d skipped, %d failed, %d cancelled'):format(batch.started or 0, batch.skipped or 0, batch.failed or 0, batch.cancelled or 0),
        batch.failed and vim.log.levels.WARN or vim.log.levels.INFO,
        { title = 'Java' }
      )
    end
  end

  function runner:finish_task(task, result)
    if self.launch_task ~= task then return end
    self:settle_task(task, result or 'cancelled')
    self.launch_task = nil
    vim.schedule(function() self:process_queue() end)
  end

  function runner:prepare_task(task, config)
    if self.launch_task ~= task then return end
    if task.mode == 'run' then
      local existing = self.runs[run_key(config)]
      if existing and existing.job_id then
        self:finish_task(task, 'skipped')
        return
      end
    end
    preparation:prepare(config, task.bufnr, function(err, prepared)
      if self.launch_task ~= task then return end
      local result = 'failed'
      if err then
        if err.kind == 'cancelled' then result = 'cancelled' end
        if err.kind ~= 'cancelled' then vim.notify(error_message(err), vim.log.levels.ERROR, { title = 'Java' }) end
      else
        local ok, status = pcall(function()
          if task.mode == 'debug' then return self:debug_config(prepared) end
          return self:run(prepared, task)
        end)
        if ok then
          result = status or 'started'
        else
          vim.notify(error_message(status), vim.log.levels.ERROR, { title = 'Java' })
        end
      end
      self:finish_task(task, result)
    end)
  end

  function runner:queue_selected(task, configurations)
    if self.launch_task ~= task then return end
    local batch = { remaining = #configurations }
    local tasks = {}
    for _, config in ipairs(configurations) do
      local target = vim.deepcopy(config)
      local child = { mode = task.mode, bufnr = task.bufnr, config = target, batch = batch, request = task.request or task }
      local ok, args = pcall(function() return launch:arguments(target) end)
      if ok then
        target.args = args
        tasks[#tasks + 1] = child
      else
        vim.notify(error_message(args), vim.log.levels.ERROR, { title = 'Java' })
        self:settle_task(child, 'failed')
      end
    end
    vim.list_extend(tasks, self.launch_queue)
    self.launch_queue = tasks
    self.launch_task = nil
    vim.schedule(function() self:process_queue() end)
  end

  function runner:select_target(task, configurations)
    if self.launch_task ~= task then return end
    if #configurations == 0 then
      vim.notify('No main class found', vim.log.levels.ERROR)
      self:finish_task(task)
    elseif #configurations == 1 and task.mode == 'debug' and not task.with_args then
      local config = vim.deepcopy(configurations[1])
      local ok, args = pcall(function() return launch:arguments(config) end)
      if not ok then
        vim.notify(error_message(args), vim.log.levels.ERROR)
        self:finish_task(task, 'failed')
        return
      end
      config.args = args
      self:prepare_task(task, config)
    else
      Picker.select(configurations, {
        prompt = task.mode == 'debug' and 'Debug Java Main' or 'Run Java Main',
        multiple = task.mode == 'run' and not task.with_args,
        describe_item = function(item) return picker_description(item) end,
        format_item = function(item) return display_name(item) end,
      }, function(selected)
        if self.launch_task ~= task then return end
        if not selected or #selected == 0 then
          self:finish_task(task)
          return
        end
        if not task.with_args then
          self:queue_selected(task, selected)
          return
        end
        local config = vim.deepcopy(selected[1])
        local ok, args = pcall(function() return launch:arguments(config) end)
        if not ok then
          vim.notify(error_message(args), vim.log.levels.ERROR)
          self:finish_task(task, 'failed')
          return
        end
        vim.ui.input({ prompt = 'Program arguments: ', default = Launch.format_args(args) }, function(input)
          if self.launch_task ~= task then return end
          if input == nil then
            self:finish_task(task)
            return
          end
          local valid, parsed = pcall(Launch.split_args, input)
          if not valid then
            vim.notify(error_message(parsed), vim.log.levels.ERROR)
            self:finish_task(task, 'failed')
            return
          end
          config.args = parsed
          self:queue_selected(task, { config })
        end)
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

  function runner:enqueue(mode, bufnr, config, with_args)
    if config then
      config = vim.deepcopy(config)
      local ok, args = pcall(function() return launch:arguments(config) end)
      if not ok then
        vim.notify(error_message(args), vim.log.levels.ERROR)
        return
      end
      config.args = args
    end
    self.launch_queue[#self.launch_queue + 1] = { mode = mode, bufnr = bufnr, config = config, with_args = with_args }
    self:process_queue()
  end

  function runner:launch(config, bufnr) self:enqueue('run', bufnr, config) end

  function runner:start(with_args)
    if not has_debug then
      vim.notify('VSC_JAVA_DEBUG is required to discover main classes', vim.log.levels.ERROR)
      return
    end
    self:enqueue('run', vim.api.nvim_get_current_buf(), nil, with_args)
  end

  function runner:debug(with_args)
    if not has_debug then
      vim.notify('VSC_JAVA_DEBUG is not configured or contains no debug bundle', vim.log.levels.ERROR)
      return
    end
    self:enqueue('debug', vim.api.nvim_get_current_buf(), nil, with_args)
  end

  function runner:stop_items(items)
    local tasks, runs = {}, {}
    for _, item in ipairs(items) do
      if item.task then tasks[item.task] = true end
      if item.run then runs[item.run] = true end
    end
    self.launch_queue = vim.tbl_filter(function(task)
      if tasks[task] then
        self:settle_task(task, 'cancelled')
        return false
      end
      return true
    end, self.launch_queue)
    local active = self.launch_task
    if active and tasks[active] then
      self.launch_task = nil
      self:settle_task(active, 'cancelled')
      preparation:cancel()
      vim.schedule(function() self:process_queue() end)
    end
    for run in pairs(runs) do
      if run.job_id and not run.stopping then
        run.stopping = true
        if vim.fn.jobstop(run.job_id) == 0 then run.stopping = false end
      end
    end
  end

  function runner:stop_candidates()
    local items, instances = {}, {}
    local function add_task(task, state)
      if task.mode ~= 'run' then return end
      local key = task.config and run_key(task.config)
      local item = key and instances[key] or nil
      if not item then
        item = { key = key, text = task.config and display_name(task.config) or 'Main discovery / selection' }
        items[#items + 1] = item
        if key then instances[key] = item end
      end
      item.tasks = item.tasks or {}
      item.tasks[#item.tasks + 1] = task
      item.text = item.text .. ' [' .. state .. ']'
    end
    for _, key in ipairs(self.run_order) do
      local run = self.runs[key]
      if run and run.job_id then
        local item = {
          key = key,
          run = run,
          request = run.request,
          text = display_name({ mainClass = run.main_class, projectName = run.project_name, args = run.args }) .. (run.stopping and ' [stopping]' or ' [running]'),
        }
        items[#items + 1] = item
        instances[key] = item
      end
    end
    if self.launch_task then add_task(self.launch_task, 'preparing') end
    for _, task in ipairs(self.launch_queue) do
      add_task(task, 'queued')
    end
    return items
  end

  function runner:stop_selected(items)
    local keys, tasks, requests = {}, {}, {}
    for _, item in ipairs(items) do
      if item.key then keys[item.key] = true end
      for _, task in ipairs(item.tasks or {}) do
        tasks[task] = true
        if not task.config then requests[task] = true end
      end
    end
    local targets = {}
    for _, item in ipairs(self:stop_candidates()) do
      local selected = (item.key and keys[item.key]) or (item.request and requests[item.request])
      for _, task in ipairs(item.tasks or {}) do
        selected = selected or tasks[task] or (task.request and requests[task.request])
      end
      if selected then
        if item.run then targets[#targets + 1] = { run = item.run } end
        for _, task in ipairs(item.tasks or {}) do
          targets[#targets + 1] = { task = task }
        end
      end
    end
    self:stop_items(targets)
  end

  function runner:stop()
    local items = self:stop_candidates()
    if #items == 0 then
      vim.notify('No running or queued Java services', vim.log.levels.INFO)
      return
    end
    Picker.select(items, {
      prompt = 'Stop Java Services',
      multiple = true,
      describe_item = function(item)
        local run = item.run
        if run then
          return picker_description({ mainClass = run.main_class, projectName = run.project_name, args = run.args }, run.stopping and 'stopping' or 'running', run.hidden)
        end
        local task = item.tasks[1]
        local status = task == self.launch_task and 'preparing' or 'queued'
        return task.config and picker_description(task.config, status) or { name = 'Main discovery / selection', status = status }
      end,
      format_item = function(item) return item.text end,
    }, function(selected)
      if selected then self:stop_selected(selected) end
    end)
  end

  function runner:stop_all() self:stop_selected(self:stop_candidates()) end

  return runner
end

return M
