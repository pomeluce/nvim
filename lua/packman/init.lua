local spec_mod = require('packman.spec')
local loader = require('packman.loader')
local ui = require('packman.ui')

local M = {}

--- 递归展开 import, 收集所有 spec
---@param specs table[]
---@return table[]
local function collect(specs)
  local result = {}
  for _, spec in ipairs(specs) do
    if type(spec) == 'table' and spec.import then
      local ok, mod = pcall(require, spec.import)
      if not ok then
        vim.notify('packman: failed to require import: ' .. spec.import, vim.log.levels.ERROR)
      elseif type(mod) == 'table' then
        vim.list_extend(result, collect(mod))
      end
      -- nil 返回值: 静默跳过(兼容未迁移的旧模块)
    elseif type(spec) == 'table' and spec[1] then
      table.insert(result, spec)
    elseif type(spec) == 'string' then
      table.insert(result, { spec })
    end
    -- nil 或空表: 跳过
  end
  return result
end

--- 初始化 packman 并加载所有插件
---@param specs table[] spec 列表(支持 import 字段)
function M.setup(specs)
  -- 1. 收集: 递归展开 import
  local all_specs = collect(specs)

  -- 2. 解析: 处理每个 spec
  local parsed = {}
  for _, spec in ipairs(all_specs) do
    table.insert(parsed, spec_mod.parse(spec))
  end

  -- 3. 注册命令（在 load 之前，因为 load 可能触发 UI）
  ui.register_commands()

  -- 4. 加载: 注册 + 配置（可能触发首次安装面板）
  loader.load(parsed)
end

--- 单插件便捷声明(可内联在 setup 列表中)
---@param src string
---@param opts table|nil
---@return table
function M.use(src, opts)
  opts = opts or {}
  opts[1] = src
  return opts
end

return M
