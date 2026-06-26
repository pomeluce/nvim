-- ==============================================================
-- 插件列表
-- ==============================================================
---@class PackUtils.Spec
---@field src string Git 仓库 URL
---@field version? string|vim.VersionRange 版本约束 (如 'v1.*') 或分支名 (如 'main')
---@field enabled? boolean|fun():boolean 是否启用 (默认 true)

---@type PackUtils.Spec[]
local specs = {
  -- 公共依赖
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/MunifTanjim/nui.nvim' },

  -- theme
  { src = 'https://github.com/RRethy/base16-nvim' },

  -- lsp
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/mfussenegger/nvim-jdtls' },

  -- manson
  { src = 'https://github.com/mason-org/mason.nvim', enabled = require('settings').mason.enable },
  { src = 'https://github.com/williamboman/mason-lspconfig.nvim', enabled = require('settings').mason.enable },
  { src = 'https://github.com/jay-babu/mason-nvim-dap.nvim', enabled = require('settings').mason.enable },

  -- completion
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('v1.*') },
  { src = 'https://github.com/xzbdmw/colorful-menu.nvim' },
  { src = 'https://github.com/fang2hou/blink-copilot' },
  { src = 'https://github.com/L3MON4D3/LuaSnip', version = vim.version.range('v2.*') },
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
  { src = 'https://github.com/archie-judd/blink-cmp-words' },
  { src = 'https://github.com/Kaiser-Yang/blink-cmp-avante' },
  { src = 'https://github.com/windwp/nvim-autopairs' },

  -- debugging
  { src = 'https://github.com/mfussenegger/nvim-dap' },
  { src = 'https://github.com/rcarriga/nvim-dap-ui' },
  { src = 'https://github.com/theHamsta/nvim-dap-virtual-text' },
  { src = 'https://github.com/nvim-neotest/nvim-nio' },

  -- format
  { src = 'https://github.com/stevearc/conform.nvim' },

  -- treesitter
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-context' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects', version = 'main' },

  -- edit
  { src = 'https://github.com/windwp/nvim-ts-autotag' },
  { src = 'https://github.com/yetone/avante.nvim', enabled = false },
  { src = 'https://github.com/coder/claudecode.nvim' },
  { src = 'https://github.com/folke/ts-comments.nvim' },
  { src = 'https://github.com/kylechui/nvim-surround' },
  { src = 'https://github.com/AndrewRadev/switch.vim' },

  -- ui
  { src = 'https://github.com/brenoprata10/nvim-highlight-colors' },
  { src = 'https://github.com/lukas-reineke/indent-blankline.nvim' },
  { src = 'https://github.com/nvim-mini/mini.icons' },
  { src = 'https://github.com/folke/noice.nvim' },

  -- layout
  { src = 'https://github.com/Bekaboo/dropbar.nvim' },
  { src = 'https://github.com/rebelot/heirline.nvim' },
  { src = 'https://github.com/nvim-mini/mini.files' },
  { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
  { src = 'https://github.com/folke/snacks.nvim' },
  { src = 'https://github.com/akinsho/toggleterm.nvim' },
  { src = 'https://github.com/kevinhwang91/nvim-ufo' },
  { src = 'https://github.com/kevinhwang91/promise-async' },

  -- navigation
  { src = 'https://github.com/folke/flash.nvim' },

  -- git
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },

  -- workspace
  { src = 'https://github.com/coffebar/neovim-project' },
  { src = 'https://github.com/Shatur/neovim-session-manager' },

  -- docs
  { src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim' },
  { src = 'https://github.com/danymat/neogen' },
  { src = 'https://github.com/folke/todo-comments.nvim' },
  { src = 'https://github.com/yianwillis/vimcdoc' },

  -- tools
  { src = 'https://github.com/hakonharnes/img-clip.nvim' },
  { src = 'https://github.com/esmuellert/codediff.nvim' },
  { src = 'https://github.com/brianhuster/live-preview.nvim' },
  { src = 'https://github.com/uga-rosa/translate.nvim' },
  { src = 'https://github.com/linux-cultist/venv-selector.nvim' },
  { src = 'https://github.com/mistweaverco/kulala.nvim' },
}
-- 在 spec 中设置 enabled = false 可禁用插件:
--   不会加载, 不会下载(如果是新添加的), 已在硬盘上不会被删除
--   enabled 支持 boolean | function → boolean, 例如:
--     { src = 'https://...', enabled = false }
--     { src = 'https://...', enabled = function() return vim.fn.executable('some-tool') == 1 end }

-- ==============================================================
-- Pack 管理命令
-- ==============================================================

-- 获取所有已安装插件的名称列表(用于 Tab 补全)
local function get_plugin_names(arg_lead)
  local installed = vim.pack.get(nil, { info = false })
  local names = {}
  for _, p in ipairs(installed) do
    local name = p.spec.name
    -- 只添加匹配开头字符串的插件
    if name:lower():find(arg_lead:lower(), 1, true) == 1 then table.insert(names, name) end
  end
  -- 排序让补全列表更整洁
  table.sort(names)
  return names
end

-- :PkUpdate 命令更新插件, 不带参数更新全部, 默认显示审查界面(需按 :w 确认)；可以加 ! 强制直接更新
vim.api.nvim_create_user_command('PkUpdate', function(opts)
  local targets = #opts.fargs > 0 and opts.fargs or nil
  local force = opts.bang -- 如果输入了 PackUpdate! 则 opts.bang 为 true
  if targets then
    vim.notify('Checking updates for: ' .. table.concat(targets, ', '), vim.log.levels.INFO)
  else
    vim.notify('Checking updates for all plugins...', vim.log.levels.INFO)
  end
  vim.pack.update(targets, { force = force })
end, {
  nargs = '*',
  bang = true, -- 声明支持 ! 符号
  complete = get_plugin_names,
  desc = 'Update plugins (use ! to skip confirmation)',
})

-- :PkStatus 命令查看插件当前状态和版本
vim.api.nvim_create_user_command('PkStatus', function(opts)
  local targets = #opts.fargs > 0 and opts.fargs or nil
  vim.pack.update(targets, { offline = true })
end, {
  nargs = '*',
  complete = get_plugin_names,
  desc = 'Check plugin status without downloading',
})

-- ==============================================================
-- 插件管理引擎(PackUtils)(暴露给全局, 供 plugins/*.lua 调用)
-- ==============================================================
_G.PackUtils = {
  is_building = {}, -- 记录各插件的构建状态, 防止重复构建
  is_initialized = {}, -- 记录具体的配置代码块是否已执行
  plugin_loaded = {}, -- 记录插件是否已挂载(避免重复 packadd)
}

-- [解析插件名]
function PackUtils.get_name(spec)
  local url = type(spec) == 'table' and spec.src or spec
  return type(spec) == 'table' and spec.name or url:match('([^/]+)$'):gsub('%.git$', '')
end

-- [同步清理] 自动删除孤儿插件(不在 specs 中的已安装插件)
function PackUtils.sync(active_specs)
  local protected_names = {}

  -- 将 specs 中所有插件(含 enabled = false)加入受保护名单
  for _, spec in ipairs(active_specs) do
    protected_names[PackUtils.get_name(spec)] = true
  end

  -- 用 API 获取已安装列表(比文件系统扫描更快更准)
  local installed = vim.pack.get(nil, { info = false })
  local to_delete = {}
  for _, p in ipairs(installed) do
    if not protected_names[p.spec.name] then table.insert(to_delete, p.spec.name) end
  end

  if #to_delete > 0 then
    vim.schedule(function()
      vim.notify('🧹 Clean Up Orphaned Plugins: ' .. table.concat(to_delete, ', '), vim.log.levels.INFO)
      vim.pack.del(to_delete)
    end)
  end
end

-- [动态路径] 获取插件根目录
function PackUtils.get_root(name)
  name = PackUtils.get_name(name)
  local paths = vim.api.nvim_get_runtime_file('pack/*/*/' .. name, true)
  if #paths > 0 then return paths[1] end
  local glob = vim.fn.globpath(vim.o.packpath, 'pack/*/*/' .. name, false, true)
  return glob[1] or nil
end

-- [构建执行] 执行编译任务
function PackUtils.run_build(name, build_cmd)
  name = PackUtils.get_name(name)
  if not build_cmd or PackUtils.is_building[name] then return end
  local path = PackUtils.get_root(name)
  if not path then return end
  local stamp = path .. '/.build_done'
  PackUtils.is_building[name] = true

  -- 判断是否为 Neovim 内部命令 (以 : 开头)
  local is_vim_cmd = false
  local vim_cmd_str = ''

  if type(build_cmd) == 'string' and build_cmd:sub(1, 1) == ':' then
    is_vim_cmd = true
    vim_cmd_str = build_cmd:sub(2)
  elseif type(build_cmd) == 'table' and type(build_cmd[1]) == 'string' and build_cmd[1]:sub(1, 1) == ':' then
    is_vim_cmd = true
    vim_cmd_str = table.concat(build_cmd, ' '):sub(2)
  end

  if is_vim_cmd then
    -- 在当前实例的空闲时执行 vim.cmd
    vim.schedule(function()
      vim.notify('⚙️ Running ' .. name .. ' setup command...', vim.log.levels.INFO)
      -- 确保插件在当前实例已经被加载
      pcall(function() vim.cmd.packadd(name) end)
      -- 保护执行, 防止命令错误导致编辑器崩溃
      local ok, err = pcall(function() vim.cmd(vim_cmd_str) end)
      PackUtils.is_building[name] = false
      if ok then
        local f = io.open(stamp, 'w')
        if f then f:close() end
        vim.notify('✅ ' .. name .. ' setup success.', vim.log.levels.INFO)
      else
        vim.notify('❌ ' .. name .. ' setup failed: ' .. tostring(err), vim.log.levels.ERROR)
      end
    end)
  else
    local final_cmd = {}
    if type(build_cmd) == 'string' then
      for word in build_cmd:gmatch('%S+') do
        table.insert(final_cmd, word)
      end
    else
      final_cmd = build_cmd
    end
    vim.schedule(function() vim.notify('⚙️ Building ' .. name .. ' (Background)...', vim.log.levels.INFO) end)
    vim.system(final_cmd, { cwd = path }, function(out)
      PackUtils.is_building[name] = false
      if out.code == 0 then
        local f = io.open(stamp, 'w')
        if f then f:close() end
        vim.schedule(function() vim.notify('✅ ' .. name .. ' build success.', vim.log.levels.INFO) end)
      else
        vim.schedule(function() vim.notify('❌ ' .. name .. ' build failed: ' .. (out.stderr or 'Unknown Error'), vim.log.levels.ERROR) end)
      end
    end)
  end
end

-- [监听器] 注册安装/更新监听
function PackUtils.setup_listener(name, build_cmd)
  name = PackUtils.get_name(name)
  if not build_cmd then return end
  vim.api.nvim_create_autocmd('PackChanged', {
    pattern = '*',
    callback = function(ev)
      if ev.data.spec.name == name and (ev.data.kind == 'update' or ev.data.kind == 'install') then
        local stamp = ev.data.path .. '/.build_done'
        os.remove(stamp) -- 自动删除.build_done文件触发构建
        PackUtils.run_build(name, build_cmd)
      end
    end,
  })
end

-- [健康检查] 如果没标记且有构建命令, 则触发构建
function PackUtils.check_health(name, build_cmd)
  name = PackUtils.get_name(name)
  if not build_cmd then return end
  local path = PackUtils.get_root(name)
  if path then
    local stamp = path .. '/.build_done'
    if vim.fn.filereadable(stamp) == 0 then PackUtils.run_build(name, build_cmd) end
  end
end

-- [辅助] 解析 boolean | function → boolean 参数
local function resolve_flag(val)
  if val == nil then return true end
  if type(val) == 'function' then
    local ok, result = pcall(val)
    return ok and result
  end
  return val
end

-- 全方位防崩加载引擎
---@class PackUtils.PluginSpec
---@field name string 插件名或 src URL
---@field enabled? boolean|fun():boolean 是否启用 (默认 true)
---@field loaded? boolean|fun():boolean 是否执行 config_fn (默认 true)
---@field deps? string[] 依赖插件名列表
---@field build_cmd? string|string[] 构建命令
---@param P PackUtils.PluginSpec
---@param config_fn? function 可选配置函数
function PackUtils.load(P, config_fn)
  -- 生成如 "@/home/.../lua/plugins/theme.lua:24" 这样绝对唯一的 call_id
  local info = debug.getinfo(2, 'Sl')
  local call_id = (info.source or 'unknown') .. ':' .. (info.currentline or 0)

  -- 精准拦截: 如果[这一行代码]已经执行过, 直接跳过
  if PackUtils.is_initialized[call_id] then return end

  P.name = PackUtils.get_name(P.name)

  -- specs 中 enabled = false 的插件, 完全跳过
  if PackUtils.disabled_specs and PackUtils.disabled_specs[P.name] then
    PackUtils.is_initialized[call_id] = true
    return
  end

  -- enabled: boolean | function → boolean, false 时完全跳过(不 packadd、不 config)
  if not resolve_flag(P.enabled) then
    PackUtils.is_initialized[call_id] = true
    return
  end

  -- deps 规范化
  if P.deps then
    for i, dep in ipairs(P.deps) do
      P.deps[i] = PackUtils.get_name(dep)
    end
  end

  -- 磁盘中找不到, 说明它正在异步克隆下载, 直接静默退出
  if not PackUtils.get_root(P.name) then
    vim.notify('Plugin not found on disk: ' .. P.name, vim.log.levels.DEBUG)
    return
  end

  -- 插件级操作: 整个生命周期只需做一次的动作 (检查编译和挂载)
  if not PackUtils.plugin_loaded[P.name] then
    PackUtils.check_health(P.name, P.build_cmd)
    pcall(function() vim.cmd.packadd(P.name) end)

    if P.deps then
      for _, dep in ipairs(P.deps) do
        local dep_ok = pcall(function() vim.cmd.packadd(dep) end)
        if not dep_ok then vim.notify('Warning: ' .. P.name .. ' dependency [' .. dep .. '] missing', vim.log.levels.WARN) end
      end
    end
    -- 标记该仓库已挂载
    PackUtils.plugin_loaded[P.name] = true
  end

  -- ⭐ is_initialized 提前设置: config_fn 即使失败也不影响状态一致性
  PackUtils.is_initialized[call_id] = true

  -- loaded: boolean | function → boolean, false 时只 packadd 但不执行 config_fn
  if not resolve_flag(P.loaded) then return end

  -- 保护 Setup 执行: 自由地 require, 如有拼写错误, 这里的 pcall 会完美捕获并报错
  if config_fn then
    local setup_ok, err = pcall(config_fn)
    if not setup_ok then vim.notify('Error: ' .. P.name .. ' setup failed:\n' .. tostring(err), vim.log.levels.ERROR) end
  end
end

-- ==============================================================
-- 执行启动流程
-- ==============================================================

-- 过滤出启用的插件(enabled 支持 boolean | function → boolean)
local active_specs = {}
PackUtils.disabled_specs = {}
for _, spec in ipairs(specs) do
  if resolve_flag(spec.enabled) then
    table.insert(active_specs, spec)
  else
    PackUtils.disabled_specs[PackUtils.get_name(spec)] = true
  end
end

-- 同步清理孤儿插件(仅保护 enabled 的插件)
PackUtils.sync(active_specs)

-- 正式下载/注册插件(仅启用的)
vim.pack.add(active_specs)

-- 递归加载 plugins/ 下所有 Lua 文件(含子目录 init.lua)
local function load_plugin_dir(dir, prefix)
  for name, type in vim.fs.dir(dir) do
    if type == 'directory' then
      -- 子目录加载 init.lua(如 plugins/tools/ → require('plugins.tools'))
      if vim.fn.filereadable(dir .. '/' .. name .. '/init.lua') == 1 then
        local ok, err = pcall(require, prefix .. '.' .. name)
        if not ok then vim.notify('Failed to load ' .. prefix .. '.' .. name .. ': ' .. tostring(err), vim.log.levels.ERROR) end
      end
    elseif type == 'file' and name:match('%.lua$') and name ~= 'init.lua' then
      local mod = prefix .. '.' .. name:gsub('%.lua$', '')
      local ok, err = pcall(require, mod)
      if not ok then vim.notify('Failed to load ' .. mod .. ': ' .. tostring(err), vim.log.levels.ERROR) end
    end
  end
end

local config_path = vim.fn.stdpath('config') .. '/lua/plugins'
if vim.fn.isdirectory(config_path) == 1 then load_plugin_dir(config_path, 'plugins') end
