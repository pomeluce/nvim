local M = {}

---@type table<string, number> 插件名 -> 加载耗时(ms)
M.load_times = {}

--- 记录加载耗时
---@param name string
---@param ms number
function M.record(name, ms) M.load_times[name] = ms end

--- 获取排序后的加载时间(降序)
---@return table[]
function M.get_sorted()
  local sorted = {}
  for name, ms in pairs(M.load_times) do
    table.insert(sorted, { name = name, ms = ms })
  end
  table.sort(sorted, function(a, b) return a.ms > b.ms end)
  return sorted
end

--- 获取总加载时间
---@return number
function M.total()
  local total = 0
  for _, ms in pairs(M.load_times) do
    total = total + ms
  end
  return total
end

--- 清除缓存
function M.clear() M.load_times = {} end

return M
