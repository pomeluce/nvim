local spec_mod = require('packman.spec')
local registry = require('packman.registry')
local cache = require('packman.cache')

local M = {}

--- 解析 opts(支持 function 类型延迟求值)
---@param opts any
---@return any
local function resolve_opts(opts)
  if type(opts) == 'function' then return opts() end
  return opts
end

--- 获取 Lua 模块名
---@param plugin table
---@return string
local function get_main(plugin)
  if plugin.main then return plugin.main end
  return spec_mod.infer_main(plugin.name)
end

--- 加载单个插件(require + config/setup)
---@param plugin table
---@param dependency_chain? table<string, boolean> 已加载的依赖，防止循环
local function load_plugin(plugin, dependency_chain)
  dependency_chain = dependency_chain or {}

  if registry.is_loaded(plugin.name) then
    return -- 已加载，跳过
  end
  if dependency_chain[plugin.name] then
    return -- 防止循环依赖
  end
  dependency_chain[plugin.name] = true

  local start = vim.uv.hrtime()

  -- 先加载依赖
  if plugin.dependencies then
    for _, dep in ipairs(plugin.dependencies) do
      local dep_spec = spec_mod.parse(dep)
      load_plugin(dep_spec, dependency_chain)
    end
  end

  -- 延迟加载的插件: 重新调用 vim.pack.add() 使其生效(不带 load=false)
  if spec_mod.is_lazy(plugin) then
    local pack_spec = { src = plugin.src, name = plugin.name }
    if plugin.version then pack_spec.version = plugin.version end
    vim.pack.add({ pack_spec })
  end

  -- 执行配置
  if plugin.config then
    plugin.config()
  elseif plugin.opts then
    local main = get_main(plugin)
    local ok, mod = pcall(require, main)
    if ok and mod and type(mod.setup) == 'function' then mod.setup(resolve_opts(plugin.opts)) end
  end

  registry.mark_loaded(plugin.name)

  local elapsed = (vim.uv.hrtime() - start) / 1e6
  cache.record(plugin.name, elapsed)
end

--- 注册插件到 vim.pack.add()
---@param plugin table
local function register_plugin(plugin)
  local pack_spec = { src = plugin.src, name = plugin.name }
  if plugin.version then pack_spec.version = plugin.version end

  if spec_mod.is_lazy(plugin) then
    vim.pack.add({ pack_spec }, { load = false })
    registry.mark_lazy(plugin.name)
  else
    vim.pack.add({ pack_spec })
  end
  registry.add(plugin.name, plugin)
end

--- 创建延迟加载钩子
---@param plugin table
local function create_hooks(plugin)
  local group_name = 'packman:' .. plugin.name

  if plugin.event then
    local events = type(plugin.event) == 'table' and plugin.event or { plugin.event }
    vim.api.nvim_create_autocmd(events, {
      group = vim.api.nvim_create_augroup(group_name, { clear = true }),
      once = true,
      callback = function() load_plugin(plugin) end,
    })
  end

  if plugin.ft then
    local fts = type(plugin.ft) == 'table' and plugin.ft or { plugin.ft }
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup(group_name, { clear = true }),
      pattern = fts,
      once = true,
      callback = function() load_plugin(plugin) end,
    })
  end

  if plugin.cmd then
    local cmds = type(plugin.cmd) == 'table' and plugin.cmd or { plugin.cmd }
    for _, cmd in ipairs(cmds) do
      vim.api.nvim_create_user_command(cmd, function(opts)
        load_plugin(plugin)
        vim.cmd({ cmd = cmd, args = opts.fargs, bang = opts.bang })
      end, { nargs = '*', bang = true, desc = 'Lazy-load ' .. plugin.name })
    end
  end

  if plugin.keys then
    local key_specs = type(plugin.keys[1]) == 'table' and plugin.keys or { plugin.keys }
    for _, ks in ipairs(key_specs) do
      local key = type(ks) == 'table' and ks[1] or ks
      local mode = type(ks) == 'table' and ks.mode or { 'n' }
      if type(mode) == 'string' then mode = { mode } end
      vim.keymap.set(mode, key, function()
        -- 删除映射
        for _, m in ipairs(mode) do
          pcall(vim.keymap.del, m, key)
        end
        load_plugin(plugin)
        -- 重新触发原始按键
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), 'm', false)
      end, { desc = 'Lazy-load ' .. plugin.name })
    end
  end
end

--- 递归注册插件及其所有依赖
---@param plugin table
local function register_with_deps(plugin)
  if registry.is_loaded(plugin.name) or registry.is_declared(plugin.name) then return end
  if plugin.dependencies then
    for _, dep in ipairs(plugin.dependencies) do
      local dep_spec = spec_mod.parse(dep)
      register_with_deps(dep_spec)
    end
  end
  register_plugin(plugin)
end

--- 加载所有插件
---@param plugins table[] 已解析的 spec 列表
function M.load(plugins)
  -- 第一遍: 注册所有插件及其依赖到 vim.pack, 确保所有插件在 runtimepath 上
  for _, plugin in ipairs(plugins) do
    if not plugin.enabled then goto continue end
    register_with_deps(plugin)
    ::continue::
  end

  -- 第二遍: 加载非延迟插件、创建延迟加载钩子
  for _, plugin in ipairs(plugins) do
    if not plugin.enabled then goto continue end

    if spec_mod.is_lazy(plugin) then
      create_hooks(plugin)
    else
      load_plugin(plugin)
    end

    ::continue::
  end

  -- 第三遍: 检测缺失插件，触发自动安装
  local installed = {}
  for _, p in ipairs(vim.pack.get(nil, { info = true }) or {}) do
    if p.spec and p.spec.name then installed[p.spec.name] = true end
  end

  local missing = {}
  for _, plugin in ipairs(plugins) do
    if plugin.enabled and not installed[plugin.name] then
      table.insert(missing, plugin.name)
    end
  end

  if #missing > 0 then
    vim.schedule(function()
      local ui = require('packman.ui')
      ui.open('update')
      ui.do_install(missing)
    end)
  end
end

return M
