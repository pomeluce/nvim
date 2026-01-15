local register = vim.api.nvim_create_user_command
local pack = require('configs.pack')

-- 插件列表
register('PackInstalled', function()
  local installed = pack.installed_plugins() or {}
  if #installed == 0 then
    vim.notify('No installed plugins found', vim.log.levels.INFO)
    return
  end

  local lock_path = pack.find_lock_file()
  local lock = nil
  if lock_path then
    local content = require('utils').read_file(lock_path)
    if content and content ~= '' then
      local ok, parsed = pcall(vim.json.decode, content)
      if ok and type(parsed) == 'table' then lock = parsed end
    end
  end
  local lock_plugins = (lock and lock.plugins) or {}

  local lines, highlights = pack.build_lines_and_highlights(installed, lock_plugins)

  pack.open_floating_window(lines, highlights)
end, { nargs = 0, desc = 'Show installed plugins in a floating window' })

-- 插件更新
register('PackUpdate', function() vim.pack.update() end, { nargs = 0, desc = 'Run vim.pack.update() and show result' })

-- 插件删除
register('PackRemove', function(opts)
  local name = vim.trim(opts.args or '')
  if name == '' then
    vim.notify('PackRemove requires a plugin name', vim.log.levels.ERROR)
    return
  end

  local ok, err = pcall(function() vim.pack.del({ name }) end)
  if not ok then
    vim.notify('Failed to remove plugin: ' .. tostring(err), vim.log.levels.ERROR)
    return
  end
  vim.notify('Removed plugin: ' .. name)
end, { nargs = 1, complete = function(arg_lead) return pack.installed_complete(arg_lead) end, desc = 'Run vim.pack.del() remove you input plugin' })

-- 插件清理
register('PackClean', function()
  local padding = string.rep(' ', 2)
  -- 已安装插件
  local installed = {}
  for _, p in ipairs(vim.pack.get(nil, { info = true })) do
    if p.spec and p.spec.name then installed[p.spec.name] = true end
  end

  -- 未声明插件 = installed - declared
  local unused = {}
  for name, _ in pairs(installed) do
    if not pack.declared[name] then table.insert(unused, name) end
  end

  if #unused == 0 then
    vim.notify('No unused plugins 🎉')
    return
  end

  table.sort(unused)

  local msg = padding .. 'Remove unused plugins?\n\n' .. padding .. table.concat(unused, '\n' .. padding)
  local confirm = vim.fn.input(msg .. '\n\n' .. padding .. "Type '[Y]es' to confirm: ")
  confirm = confirm:lower()
  if confirm ~= 'y' and confirm ~= 'yes' then
    vim.notify('PackClean cancelled')
    return
  end

  vim.pack.del(unused)
  -- vim.notify('Removed plugins:\n' .. table.concat(unused, '\n'))
end, { desc = 'Run vim.pack.del() remove all unused plugin' })

-- 文件保存
register('IntelliSave', function()
  -- 如果目录不存在, 创建目录
  if vim.fn.empty(vim.fn.glob(vim.fn.expand('%:p:h'))) == 1 then vim.fn.system('mkdir -p ' .. vim.fn.expand('%:p:h')) end
  -- 写入文件
  vim.cmd('w')
end, { nargs = 0, desc = 'file intelligence saving' })

-- 文本替换命令
register('ReplaceWord', function(opts)
  local range = opts.args
  -- 输入查找词
  vim.ui.input({ prompt = 'Replace: ' }, function(pattern)
    if not pattern or pattern == '' then return end

    -- 输入替换词
    vim.ui.input({ prompt = 'With: ' }, function(repl)
      if repl == nil then return end

      -- 询问是否确认每次替换
      local want_confirm = vim.fn.confirm('Confirm each replacement?', '&Yes\n&No', 2) == 1

      -- 使用 \V (very nomagic) 使 pattern 被视为字面内容, 不需要转义
      -- 使用 vim.fn.escape 给 pattern/repl 处理分隔符和替换中特殊符号(如 &、/、\ 等)
      local pat_esc = vim.fn.escape(pattern, '\\/')
      local repl_esc = vim.fn.escape(repl, '\\/&')

      local flags = 'g'
      if want_confirm then flags = flags .. 'c' end

      -- 构造并执行命令
      local cmd = string.format('%s s/\\V%s/%s/%s', range, pat_esc, repl_esc, flags)
      -- 如果是全缓冲范围, range = '%' -> "% s/..."
      -- 如果是可视范围, range = "'<,'>" -> "'<,'> s/..."
      vim.cmd(cmd)
    end)
  end)
end, { nargs = 1, range = true, desc = 'replace word with confirm' })

-- 重设tab长度
register('SetTab', function(opts)
  local tab_len = opts.args
  if vim.fn.empty(tab_len) == 0 then
    vim.o.shiftwidth = tonumber(tab_len)
    vim.o.softtabstop = tonumber(tab_len)
    vim.o.tabstop = tonumber(tab_len)
  else
    local l_tab_len = vim.fn.input('input shiftwidth: ')
    if vim.fn.empty(l_tab_len) == 0 then
      vim.o.shiftwidth = tonumber(l_tab_len)
      vim.o.softtabstop = tonumber(l_tab_len)
      vim.o.tabstop = tonumber(l_tab_len)
    end
  end

  vim.cmd('redraw!')
  print('shiftwidth: ' .. vim.o.shiftwidth)
end, { nargs = '?', desc = 'set tab width' })

-- 设置高亮
register('SetHL', function(opts)
  local hls = loadstring('return ' .. opts.args)()
  local colormode = vim.o.termguicolors and '' or 'cterm'
  for group, color in pairs(hls) do
    local opt = {}
    if color.fg then opt[colormode .. 'fg'] = color.fg end
    if color.bg then opt[colormode .. 'bg'] = color.bg end
    opt.bold = color.bold
    opt.underline = color.underline
    opt.italic = color.italic
    opt.strikethrough = color.strikethrough
    vim.api.nvim_set_hl(0, group, opt)
  end
end, { nargs = 1, desc = 'set highlight groups' })
