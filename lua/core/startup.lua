local Startup = {}

local tool_commands = {}
local resolved_callbacks = {}
local resolved = false
local tool_launch = false

local function has_ex_command(command, argv)
  for index, arg in ipairs(argv) do
    if arg == '+' .. command or arg == '-c' .. command then return true end
    if arg == '-c' and argv[index + 1] == command then return true end
  end
  return false
end

---@param command string
---@param callback fun(args: vim.api.keyset.create_user_command.command_args)
---@param opts? vim.api.keyset.user_command
function Startup.register_tool_command(command, callback, opts)
  if resolved then error('Cannot register tool command after startup has been resolved') end
  vim.api.nvim_create_user_command(command, callback, opts or {})
  tool_commands[command] = true
end

---@param callback function
function Startup.on_resolved(callback)
  if resolved then
    callback()
    return
  end
  resolved_callbacks[#resolved_callbacks + 1] = callback
end

---@param argv? string[]
function Startup.resolve(argv)
  if resolved then return end
  argv = argv or vim.v.argv
  for command in pairs(tool_commands) do
    if has_ex_command(command, argv) then
      tool_launch = true
      break
    end
  end
  resolved = true

  local callbacks = resolved_callbacks
  resolved_callbacks = {}
  for _, callback in ipairs(callbacks) do
    local ok, err = pcall(callback)
    if not ok then vim.notify('Startup resolution callback failed: ' .. tostring(err), vim.log.levels.ERROR) end
  end
end

---@return boolean
function Startup.is_tool_launch()
  if not resolved then error('Startup has not been resolved') end
  return tool_launch
end

return Startup
