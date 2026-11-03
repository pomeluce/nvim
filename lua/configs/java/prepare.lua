local Runtime = require('configs.java.runtime')
local Workspace = require('configs.java.workspace')

local M = {}
local BUILD_FAILED = 0
local BUILD_SUCCEEDED = 1
local BUILD_WITH_ERRORS = 2
local BUILD_CANCELLED = 3
local DISCOVERY_TIMEOUT = 15000
local RESOLVE_TIMEOUT = 15000
local BUILD_TIMEOUT = 120000
local RETRY_DELAYS = { 200, 500 }

---@class JavaLaunchTarget
---@field cwd string
---@field type 'java'
---@field request 'launch'
---@field name string
---@field projectName string
---@field mainClass string
---@field modulePaths? string[]
---@field classPaths? string[]
---@field javaExec? string
---@field vmArgs? string
---@field args? string
---@field env? table<string, string>

---@class JavaPrepareError
---@field kind string
---@field message string

---@class JavaPrepareOperation
---@field callback fun(err?: JavaPrepareError|any, result?: any)
---@field silent boolean
---@field done boolean
---@field timer? uv.uv_timer_t
---@field request_id? integer
---@field client? vim.lsp.Client
---@field has_progress? boolean

---@param err any
---@return string
local function error_message(err)
  if type(err) == 'table' then return err.message or vim.inspect(err) end
  return tostring(err)
end

---@param timer? uv.uv_timer_t
local function stop_timer(timer)
  if timer and not timer:is_closing() then
    timer:stop()
    timer:close()
  end
end

---@param root_dir string
---@param runtimes table[]
function M.new(root_dir, runtimes)
  local workspace = Workspace.new(root_dir)
  ---@type JavaPrepareOperation?
  local active
  local notification_id = 'java-launch-' .. vim.fn.sha256(root_dir):sub(1, 12)

  ---@param bufnr integer
  ---@return vim.lsp.Client?
  local function client_for(bufnr)
    local attached = vim.lsp.get_clients({ name = 'jdtls', bufnr = bufnr })[1]
    if attached then return attached end
    for _, client in ipairs(vim.lsp.get_clients({ name = 'jdtls' })) do
      if vim.fs.normalize(client.config.root_dir or '') == root_dir then return client end
    end
  end

  ---@param op JavaPrepareOperation
  ---@param message string
  ---@param level? integer
  local function update_progress(op, message, level)
    if op.silent then return end
    local snacks = rawget(_G, 'Snacks')
    if snacks and snacks.notifier then
      snacks.notifier.notify(message, level or vim.log.levels.INFO, {
        id = notification_id,
        title = 'Java',
        timeout = false,
      })
      op.has_progress = true
    elseif not op.has_progress then
      vim.notify(message, level or vim.log.levels.INFO, { title = 'Java' })
      op.has_progress = true
    end
  end

  ---@param op JavaPrepareOperation
  local function hide_progress(op)
    if not op.has_progress then return end
    local snacks = rawget(_G, 'Snacks')
    if snacks and snacks.notifier then snacks.notifier.hide(notification_id) end
  end

  ---@param op JavaPrepareOperation
  ---@param err? JavaPrepareError|any
  ---@param result? any
  local function complete(op, err, result)
    if op.done then return end
    op.done = true
    stop_timer(op.timer)
    op.timer = nil
    op.request_id = nil
    if active == op then active = nil end
    hide_progress(op)
    op.callback(err, result)
  end

  ---@param callback fun(err?: JavaPrepareError|any, result?: any)
  ---@param silent boolean
  ---@return JavaPrepareOperation?
  local function begin(callback, silent)
    if active then
      vim.schedule(function() callback({ kind = 'busy', message = 'Another Java launch operation is already in progress' }) end)
      return
    end
    ---@type JavaPrepareOperation
    local op = { callback = callback, silent = silent, done = false }
    active = op
    return op
  end

  ---@param op JavaPrepareOperation
  ---@param bufnr integer
  ---@param command string
  ---@param arguments any
  ---@param timeout integer
  ---@param callback fun(err?: any, result?: any)
  local function request(op, bufnr, command, arguments, timeout, callback)
    if op.done then return end
    local client = client_for(bufnr)
    if not client then
      complete(op, { kind = 'client', message = 'No jdtls client attached' })
      return
    end

    local settled = false
    local function settle(err, result)
      if settled or op.done then return end
      settled = true
      stop_timer(op.timer)
      op.timer = nil
      op.request_id = nil
      callback(err, result)
    end

    op.timer = vim.defer_fn(function()
      if settled or op.done then return end
      settled = true
      if op.request_id then client:cancel_request(op.request_id) end
      op.request_id = nil
      op.timer = nil
      callback({ kind = 'timeout', message = ('Timed out while running %s'):format(command) })
    end, timeout)

    local ok, request_id = client:request('workspace/executeCommand', {
      command = command,
      arguments = arguments,
    }, function(err, result)
      vim.schedule(function() settle(err, result) end)
    end, bufnr)
    if not ok then
      settle({ kind = 'request', message = ('Could not start %s'):format(command) })
      return
    end
    op.client = client
    op.request_id = request_id
  end

  ---@class JavaPreparation
  local preparation = {}

  local function synchronize(op, bufnr, next_step)
    workspace:sync(client_for(bufnr), bufnr, function(err)
      if op.done then return end
      if err then
        complete(op, err)
      else
        next_step()
      end
    end)
  end

  ---@param bufnr integer
  ---@param callback fun(err?: JavaPrepareError|any, targets?: JavaLaunchTarget[])
  function preparation:discover(bufnr, callback)
    local op = begin(callback, true)
    if not op then return end
    synchronize(op, bufnr, function()
      request(op, bufnr, 'vscode.java.resolveMainClass', nil, DISCOVERY_TIMEOUT, function(err, mains)
        if err then
          complete(op, err)
          return
        end
        ---@type JavaLaunchTarget[]
        local targets = {}
        for _, main in pairs(type(mains) == 'table' and mains or {}) do
          if type(main.mainClass) == 'string' and main.mainClass ~= '' then
            local project_name = type(main.projectName) == 'string' and main.projectName or ''
            targets[#targets + 1] = {
              cwd = root_dir,
              type = 'java',
              request = 'launch',
              name = ('Launch %s: %s'):format(project_name, main.mainClass),
              projectName = project_name,
              mainClass = main.mainClass,
            }
          end
        end
        table.sort(targets, function(left, right)
          if left.projectName == right.projectName then return left.mainClass < right.mainClass end
          return left.projectName < right.projectName
        end)
        complete(op, nil, targets)
      end)
    end)
  end

  ---@param config JavaLaunchTarget
  ---@param bufnr integer
  ---@param callback fun(err?: JavaPrepareError|any, config?: JavaLaunchTarget)
  function preparation:prepare(config, bufnr, callback)
    local op = begin(callback, false)
    if not op then return end
    local prepared = vim.deepcopy(config)
    local label = prepared.mainClass:match('([^.]+)$') or prepared.mainClass
    update_progress(op, 'Preparing Java launch: ' .. label)

    local function resolve_preview()
      request(
        op,
        bufnr,
        'vscode.java.checkProjectSettings',
        vim.json.encode({
          className = prepared.mainClass,
          projectName = prepared.projectName,
          inheritedOptions = true,
          expectedOptions = { ['org.eclipse.jdt.core.compiler.problem.enablePreviewFeatures'] = 'enabled' },
        }),
        RESOLVE_TIMEOUT,
        function(_, enabled)
          if enabled then prepared.vmArgs = prepared.vmArgs and (prepared.vmArgs .. ' --enable-preview') or '--enable-preview' end
          complete(op, nil, prepared)
        end
      )
    end

    local function resolve_runtime()
      local declared_version = Runtime.buffer_version(bufnr)
      local declared_home = Runtime.java_home(runtimes, declared_version)
      if declared_version and declared_home then
        prepared.javaExec = vim.fs.joinpath(declared_home, 'bin', 'java')
        resolve_preview()
        return
      end

      local function resolve_compliance()
        request(op, bufnr, 'java.project.getSettings', { vim.uri_from_bufnr(bufnr), { 'org.eclipse.jdt.core.compiler.compliance' } }, RESOLVE_TIMEOUT, function(err, result)
          local compliance = type(result) == 'table' and result['org.eclipse.jdt.core.compiler.compliance'] or nil
          if err or not compliance then update_progress(op, 'Could not resolve project Java version; using the configured fallback JDK', vim.log.levels.WARN) end
          local fallback_home = Runtime.java_home(runtimes, compliance)
          prepared.javaExec = fallback_home and vim.fs.joinpath(fallback_home, 'bin', 'java') or vim.fn.exepath('java')
          if prepared.javaExec == '' then prepared.javaExec = 'java' end
          resolve_preview()
        end)
      end

      request(op, bufnr, 'vscode.java.resolveJavaExecutable', { prepared.mainClass, prepared.projectName }, RESOLVE_TIMEOUT, function(err, java_exec)
        if not err and type(java_exec) == 'string' and java_exec ~= '' then
          prepared.javaExec = java_exec
          resolve_preview()
          return
        end
        resolve_compliance()
      end)
    end

    local classpath_attempt = 0
    local function resolve_classpath()
      classpath_attempt = classpath_attempt + 1
      request(op, bufnr, 'vscode.java.resolveClasspath', { prepared.mainClass, prepared.projectName }, RESOLVE_TIMEOUT, function(err, paths)
        if err then
          local message = error_message(err)
          local delay = RETRY_DELAYS[classpath_attempt]
          if delay and message:find('Referenced classpath provider does not exist', 1, true) then
            update_progress(op, ('Retrying Java classpath (%d/%d): %s'):format(classpath_attempt, #RETRY_DELAYS, label), vim.log.levels.WARN)
            op.timer = vim.defer_fn(function()
              op.timer = nil
              resolve_classpath()
            end, delay)
            return
          end
          complete(op, { kind = 'classpath', message = 'Failed to resolve Java classpath: ' .. message })
          return
        end
        if type(paths) ~= 'table' then
          complete(op, { kind = 'classpath', message = 'JDTLS returned no Java classpath' })
          return
        end
        prepared.modulePaths = type(paths[1]) == 'table' and paths[1] or {}
        prepared.classPaths = type(paths[2]) == 'table' and paths[2] or {}
        resolve_runtime()
      end)
    end

    synchronize(op, bufnr, function()
      request(
        op,
        bufnr,
        'vscode.java.buildWorkspace',
        vim.json.encode({
          mainClass = prepared.mainClass,
          projectName = prepared.projectName,
          isFullBuild = true,
        }),
        BUILD_TIMEOUT,
        function(err, status)
          if err then
            complete(op, { kind = 'build', message = 'Failed to build Java workspace: ' .. error_message(err) })
          elseif status == BUILD_FAILED then
            complete(op, { kind = 'build', message = 'Java workspace build failed' })
          elseif status == BUILD_CANCELLED then
            complete(op, { kind = 'cancelled', message = 'Java workspace build was cancelled' })
          elseif status == BUILD_WITH_ERRORS then
            complete(op, { kind = 'build', message = 'Java workspace build completed with errors; fix the diagnostics before launching' })
          elseif status ~= BUILD_SUCCEEDED then
            complete(op, { kind = 'build', message = 'JDTLS returned an unknown Java workspace build status' })
          else
            resolve_classpath()
          end
        end
      )
    end)
  end

  function preparation:cancel()
    local op = active
    if not op then return false end
    if op.request_id and op.client then op.client:cancel_request(op.request_id) end
    complete(op, { kind = 'cancelled', message = 'Java launch preparation cancelled' })
    return true
  end

  return preparation
end

return M
