local M = {}

---@type table<string, true>
M.declared = {}

---@type table<string, true>
M.loaded = {}

---@type table<string, true>
M.lazy = {}

--- 注册已声明的插件
---@param name string
function M.add(name) M.declared[name] = true end

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
end

return M
