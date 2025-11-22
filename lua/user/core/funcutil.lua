local M = {}

-- 文件保存
function M.save()
  -- 如果目录不存在, 创建目录
  if vim.fn.empty(vim.fn.glob(vim.fn.expand('%:p:h'))) == 1 then
    vim.fn.system('mkdir -p ' .. vim.fn.expand('%:p:h'))
  end
  -- 写入文件
  vim.cmd('w')
end

vim.cmd('com! AkirSave lua require("user.core.funcutil").save()')

-- 重设tab长度
function M.switchTab(tab_len)
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
end

vim.cmd('command! -nargs=* SetTab lua require("user.core.funcutil").switchTab(<q-args>)')

-- 代码折叠
function M.fold()
  local spacetext = ('        '):sub(0, vim.opt.shiftwidth:get())
  local line = vim.fn.getline(vim.v.foldstart):gsub('\t', spacetext)
  local folded = vim.v.foldend - vim.v.foldstart + 1
  local findresult = line:find('%S')
  if not findresult then
    return '+ folded ' .. folded .. ' lines '
  end
  local empty = findresult - 1
  local funcs = {
    [0] = function(_)
      return '' .. line
    end,
    [1] = function(_)
      return '+' .. line:sub(2)
    end,
    [2] = function(_)
      return '+ ' .. line:sub(3)
    end,
    [-1] = function(c)
      local result = ' ' .. line:sub(c + 1)
      local foldednumlen = #tostring(folded)
      for _ = 1, c - 2 - foldednumlen do
        result = '-' .. result
      end
      return '+' .. folded .. result
    end,
  }
  return funcs[empty <= 2 and empty or -1](empty) .. ' folded ' .. folded .. ' lines '
end

vim.cmd('com! AkirFold lua require("user.core.funcutil").fold()')

-- space 行首行尾跳转
function M.jump()
  local l_first, l_head = 1, vim.fn.len(vim.fn.getline('.')) - vim.fn.len(vim.fn.substitute(vim.fn.getline('.'), '^\\s*', '', 'G')) + 1
  local l_before = vim.fn.col('.')
  vim.cmd(l_before == l_first and l_first ~= l_head and 'norm! ^' or 'norm! $')
  local l_after = vim.fn.col('.')
  if l_before == l_after then
    vim.cmd('norm! 0')
  end
end

vim.cmd('com! AkirJump lua require("user.core.funcutil").jump()')

function M.replaceWord(range)
  -- 输入查找词
  vim.ui.input({ prompt = 'Replace: ' }, function(pattern)
    if not pattern or pattern == '' then
      return
    end

    -- 输入替换词
    vim.ui.input({ prompt = 'With: ' }, function(repl)
      if repl == nil then
        return
      end

      -- 询问是否确认每次替换
      local want_confirm = vim.fn.confirm('Confirm each replacement?', '&Yes\n&No', 2) == 1

      -- 使用 \V (very nomagic) 使 pattern 被视为字面内容, 不需要转义
      -- 使用 vim.fn.escape 给 pattern/repl 处理分隔符和替换中特殊符号(如 &、/、\ 等)
      local pat_esc = vim.fn.escape(pattern, '\\/')
      local repl_esc = vim.fn.escape(repl, '\\/&')

      local flags = 'g'
      if want_confirm then
        flags = flags .. 'c'
      end

      -- 构造并执行命令
      local cmd = string.format('%s s/\\V%s/%s/%s', range, pat_esc, repl_esc, flags)
      -- 如果是全缓冲范围, range = '%' -> "% s/..."
      -- 如果是可视范围, range = "'<,'>" -> "'<,'> s/..."
      vim.cmd(cmd)
    end)
  end)
end

vim.cmd('command! -nargs=1 ReplaceWord lua require("user.core.funcutil").replaceWord(<q-args>)')

-- 设置高亮
function M.hl(hls)
  local colormode = vim.o.termguicolors and '' or 'cterm'
  for group, color in pairs(hls) do
    local opt = color
    if color.fg then
      opt[colormode .. 'fg'] = color.fg
    end
    if color.bg then
      opt[colormode .. 'bg'] = color.bg
    end
    opt.bold = color.bold
    opt.underline = color.underline
    opt.italic = color.italic
    opt.strikethrough = color.strikethrough
    vim.api.nvim_set_hl(0, group, opt)
  end
end

-- 替代 lspconfig.util.root_pattern
function M.root_pattern(...)
  -- 内部 helper: 递归扁平化参数列表
  local function tbl_flatten(t)
    local out = {}
    local function _f(v)
      if type(v) == 'table' then
        for _, x in ipairs(v) do
          _f(x)
        end
      else
        out[#out + 1] = v
      end
    end
    _f(t)
    return out
  end

  -- 内部 helper: strip zip/tar archive subpath
  local function strip_archive_subpath(path)
    if not path or path == '' then
      return path
    end
    path = vim.fn.substitute(path, 'zipfile://\\(.\\{-}\\)::[^\\\\].*$', '\\1', '')
    path = vim.fn.substitute(path, 'tarfile:\\(.\\{-}\\)::.*$', '\\1', '')
    return path
  end

  -- 扁平化并构造 patterns 列表
  local patterns = tbl_flatten { ... }

  -- 归一化 startpath: nil / buffer id / file:// URI / file -> dirname / fallback cwd
  local function normalize_startpath(sp)
    sp = strip_archive_subpath(sp)

    if not sp or sp == '' then
      sp = vim.api.nvim_buf_get_name(0)
    end

    if type(sp) == 'number' then
      sp = vim.api.nvim_buf_get_name(sp)
    end

    if type(sp) == 'string' and sp:match('^file://') then
      if vim.uri_to_fname then
        local ok, p = pcall(vim.uri_to_fname, sp)
        if ok and p then
          sp = p
        else
          sp = sp:gsub('^file://', '')
        end
      else
        sp = sp:gsub('^file://', '')
      end
    end

    local stat = nil
    if type(sp) == 'string' or sp ~= '' then
      stat = vim.loop.fs_stat(sp)
    end

    -- 如果是文件则使用所在目录
    if stat and stat.type == 'file' then
      if vim.fs and type(vim.fs.dirname) == 'function' then
        sp = vim.fs.dirname(sp)
      else
        sp = vim.fn.fnamemodify(sp, ':h')
      end
    end

    return sp
  end

  -- 主返回函数, 行为与 lspconfig.util.root_pattern 一致: 返回 root dir 或 nil
  return function(startpath)
    local sp = normalize_startpath(startpath)
    if vim.fs and type(vim.fs.find) == 'function' then
      for _, pat in ipairs(patterns) do
        local ok, found = pcall(vim.fs.find, pat, { path = sp, upward = true, limit = 1 })
        if ok and found and found[1] then
          local dir
          if vim.fs and type(vim.fs.dirname) == 'function' then
            dir = vim.fs.dirname(found[1])
          else
            dir = vim.fn.fnamemodify(found[1], ':h')
          end
          local real = vim.loop.fs_realpath(dir)
          return real or dir
        end
      end
      return nil
    end
    return nil
  end
end

return M
