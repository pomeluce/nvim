local M = {}

---@type table<string, true>
M.declared = {}

---@type table<string, true>
M.loaded = {}

---@type table<string, true>
M.lazy = {}

---@type table<string, table> 插件名 -> 完整 parsed spec
M.specs = {}

--- 注册已声明的插件
---@param name string
---@param spec? table 完整的 parsed spec
function M.add(name, spec)
  M.declared[name] = true
  if spec then M.specs[name] = spec end
end

--- 标记为已加载
---@param name string
function M.mark_loaded(name) M.loaded[name] = true end

--- 标记为延迟加载
---@param name string
function M.mark_lazy(name) M.lazy[name] = true end

--- 判断是否已声明
---@param name string
---@return boolean
function M.is_declared(name) return M.declared[name] == true end

--- 判断是否已加载
---@param name string
---@return boolean
function M.is_loaded(name) return M.loaded[name] == true end

--- 获取所有已声明的插件名(排序)
---@return string[]
function M.get_all()
  local names = {}
  for name, _ in pairs(M.declared) do
    table.insert(names, name)
  end
  table.sort(names)
  return names
end

--- 清除所有状态
function M.clear()
  M.declared = {}
  M.loaded = {}
  M.lazy = {}
  M.specs = {}
end

--- 获取插件的完整 spec
---@param name string
---@return table?
function M.get_spec(name) return M.specs[name] end

--- 获取所有 spec（排序）
---@return table[]
function M.get_all_specs()
  local result = {}
  for name, spec in pairs(M.specs) do
    table.insert(result, spec)
  end
  table.sort(result, function(a, b) return a.name < b.name end)
  return result
end

return M
