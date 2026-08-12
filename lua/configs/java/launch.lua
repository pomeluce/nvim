local M = {}
local shell_env_keys = { OLDPWD = true, PWD = true, SHLVL = true, _ = true }

---@param path string
---@return JavaLaunchConfig
local function load_config(path)
  if vim.fn.filereadable(path) ~= 1 then return {} end
  local ok, config = pcall(dofile, path)
  if not ok then
    vim.notify(('Failed to load Java launch config %s:\n%s'):format(path, config), vim.log.levels.ERROR)
    return {}
  end
  if type(config) ~= 'table' then
    vim.notify('Java launch config must return a table: ' .. path, vim.log.levels.ERROR)
    return {}
  end
  return config
end

---@param value? JavaLaunchOptions
---@return string[]
function M.split_args(value)
  if type(value) == 'table' then return value end
  if type(value) ~= 'string' or value == '' then return {} end

  local result = {}
  local current = {}
  local quote
  local escaped = false
  local function append()
    if #current > 0 then
      result[#result + 1] = table.concat(current)
      current = {}
    end
  end
  for index = 1, #value do
    local character = value:sub(index, index)
    if escaped then
      current[#current + 1] = character
      escaped = false
    elseif character == '\\' then
      escaped = true
    elseif quote then
      if character == quote then
        quote = nil
      else
        current[#current + 1] = character
      end
    elseif character == '"' or character == "'" then
      quote = character
    elseif character:match('%s') then
      append()
    else
      current[#current + 1] = character
    end
  end
  if escaped then current[#current + 1] = '\\' end
  append()
  return result
end

local function vm_options(value)
  if type(value) == 'string' then return value end
  if type(value) ~= 'table' then return '' end
  return table.concat(vim.tbl_map(function(option) return vim.fn.shellescape(tostring(option)) end, value), ' ')
end

---@param settings JavaLaunchConfig
---@param main_class string
---@return JavaLaunchMainConfig
local function main_settings(settings, main_class)
  local value = type(settings.mainClass) == 'table' and settings.mainClass[main_class] or nil
  if type(value) == 'string' or vim.islist(value) then return { vmOptions = value } end
  return type(value) == 'table' and value or {}
end

local function merge_env(target, source)
  if type(source) ~= 'table' then return end
  for key, value in pairs(source) do
    if type(key) == 'string' and value ~= nil then target[key] = tostring(value) end
  end
end

---@param root_dir string
function M.new(root_dir)
  local config_path = vim.fs.joinpath(root_dir, '.nvim', 'java-launch.lua')

  local function load_env_file(path, inherited_env)
    path = vim.fs.normalize(vim.fn.isabsolutepath(path) == 1 and path or vim.fs.joinpath(root_dir, path))
    if vim.fn.filereadable(path) ~= 1 then
      vim.notify('Java launch env file not found: ' .. path, vim.log.levels.WARN)
      return {}
    end

    local shell = vim.fn.exepath('bash')
    if shell == '' then shell = vim.fn.exepath('sh') end
    if shell == '' then
      vim.notify('Java launch env files require bash or sh', vim.log.levels.ERROR)
      return {}
    end
    local result = vim.system({ shell, '-c', 'set -a; . "$1"; set +a; env -0', 'java-launch', path }, { cwd = root_dir, text = false }):wait()
    if result.code ~= 0 then
      local message = (result.stderr or ''):gsub('%s+$', '')
      vim.notify(('Failed to load Java launch env file %s%s'):format(path, message ~= '' and ':\n' .. message or ''), vim.log.levels.ERROR)
      return {}
    end

    local env = {}
    for _, entry in ipairs(vim.split(result.stdout or '', '\0', { plain = true, trimempty = true })) do
      local key, value = entry:match('^([^=]+)=(.*)$')
      if key and not shell_env_keys[key] and inherited_env[key] ~= value then env[key] = value end
    end
    return env
  end

  local function merge_env_files(target, value, inherited_env)
    if type(value) == 'string' then
      merge_env(target, load_env_file(value, inherited_env))
    elseif type(value) == 'table' then
      for _, path in ipairs(value) do
        if type(path) == 'string' then merge_env(target, load_env_file(path, inherited_env)) end
      end
    end
  end

  local launch = {}

  ---@param config table
  ---@return string? vm_args
  ---@return table<string, string>? env
  function launch:resolve(config)
    local settings = load_config(config_path)
    local override = main_settings(settings, config.mainClass)

    local options = {}
    local function append_options(value)
      local option = vm_options(value)
      if option ~= '' then options[#options + 1] = option end
    end
    append_options(config.vmArgs)
    append_options(settings.vmOptions)
    append_options(override.vmOptions)
    local vm_args = #options > 0 and table.concat(options, ' ') or nil

    local inherited_env = vim.fn.environ()
    local env = {}
    merge_env(env, config.env)
    merge_env_files(env, settings.envFile, inherited_env)
    merge_env(env, settings.env)
    merge_env_files(env, override.envFile, inherited_env)
    merge_env(env, override.env)
    return vm_args, next(env) and env or nil
  end

  return launch
end

return M
