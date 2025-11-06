local uv = vim.loop

local function realpath(p)
  if not p or p == '' then
    return nil
  end
  local ok, r = pcall(function()
    return uv.fs_realpath(p)
  end)
  if ok then
    return r
  end
  return nil
end

-- 先尝试直接解析可执行
local exe = vim.fn.exepath('vue-language-server')
local exe_real = realpath(exe) or realpath(vim.fn.system('which vue-language-server 2>/dev/null'):gsub('\n', ''))

local candidates = {}

if exe_real and exe_real ~= '' then
  -- exe_real 通常是 /nix/store/<hash>-vue-language-server-<ver>/bin/vue-language-server
  local store_root = vim.fn.fnamemodify(exe_real, ':h:h') -- go up two levels -> /nix/store/xxxx-...
  -- 常见 Nix 布局下放置代码的位置
  table.insert(candidates, store_root .. '/lib/language-tools')
  table.insert(candidates, store_root .. '/lib/language-tools/packages/language-server')
  table.insert(candidates, store_root .. '/lib/language-tools/node_modules/@vue/language-server')
  table.insert(candidates, store_root .. '/lib/node_modules/@vue/language-server')
end

-- Mason 安装方式
table.insert(candidates, vim.fn.stdpath('data') .. '/mason/packages/vue-language-server/node_modules/@vue/language-server')

local function exists(path)
  if not path or path == '' then
    return false
  end
  return uv.fs_stat(path) ~= nil
end

local function has_package_json(path)
  if not exists(path) then
    return false
  end
  return uv.fs_stat(path .. '/package.json') ~= nil
end

local typescript_plugin_path = nil
for _, p in ipairs(candidates) do
  if has_package_json(p) then
    typescript_plugin_path = p
    break
  end
end

-- 退回策略: 如果没有找到包含 package.json 的 candidate
-- 直接取第一个存在的 candidate(避免出现二重 node_modules 路径)
if not typescript_plugin_path then
  for _, p in ipairs(candidates) do
    if exists(p) then
      typescript_plugin_path = p
      break
    end
  end
end

if not typescript_plugin_path then
  -- 最后回退: 使用 exe_real 的 store 根并提醒
  local fallback = exe_real and (vim.fn.fnamemodify(exe_real, ':h:h') .. '/lib/language-tools') or ''
  typescript_plugin_path = fallback
  vim.notify('vue-language-server plugin path auto-detect failed; using fallback: ' .. tostring(fallback), vim.log.levels.WARN)
end

return {
  filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx', 'vue' },
  init_options = {
    plugins = {
      {
        name = '@vue/typescript-plugin',
        location = typescript_plugin_path,
        languages = { 'vue' },
        configNamespace = 'typescript',
      },
    },
  },
}
