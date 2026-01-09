local M = {}

M.declared = {}

-- 对 vim.pack.add 进行包装, 记录声明的插件
function M.pack_state()
  local orig_add = vim.pack.add

  local function infer_name_from_src(src)
    if type(src) ~= 'string' then return nil end
    -- 去掉 .git
    src = src:gsub('%.git$', '')
    -- 取最后一段
    return src:match('/([^/]+)$')
  end

  --- @param specs (string|vim.pack.Spec)[] List of plugin specifications. String item
  --- is treated as `src`.
  --- @param opts? vim.pack.keyset.add
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.pack.add = function(specs, opts)
    -- 记录声明的插件
    local function record(item)
      if type(item) == 'string' then
        -- string spec 本身就是 src
        local name = infer_name_from_src(item)
        if name then M.declared[name] = true end
      elseif type(item) == 'table' then
        -- 显式 name 优先
        if type(item.name) == 'string' then
          M.declared[item.name] = true
          return
        end
        -- src 兜底
        if type(item.src) == 'string' then
          local name = infer_name_from_src(item.src)
          if name then M.declared[name] = true end
          return
        end
      end
    end

    if type(specs) == 'table' then
      for _, item in ipairs(specs) do
        record(item)
      end
    else
      record(specs)
    end

    return orig_add(specs, opts)
  end
end

-- 返回已安装插件名称的列表(来自 vim.pack.get())
function M.installed_plugins()
  local res = vim.pack.get(nil, { info = true })
  local names = {}
  for _, plug in ipairs(res or {}) do
    local name = nil
    if plug.spec and plug.spec.name then
      name = plug.spec.name
    else
      -- fallback to basename of path
      if plug.path then name = vim.fn.fnamemodify(plug.path, ':t') end
    end
    if name then table.insert(names, name) end
  end
  table.sort(names)
  return names
end

-- 返回已安装插件名称的列表
function M.installed_complete(arg_lead)
  local items = M.installed_plugins()
  local res = {}
  for _, v in ipairs(items) do
    if vim.startswith(v, arg_lead) then table.insert(res, v) end
  end
  return res
end

return M
