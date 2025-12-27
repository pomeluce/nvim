local M = {}
local register = vim.api.nvim_create_user_command

-- 文件保存
register('IntelliSave', function()
  -- 如果目录不存在, 创建目录
  if vim.fn.empty(vim.fn.glob(vim.fn.expand('%:p:h'))) == 1 then
    vim.fn.system('mkdir -p ' .. vim.fn.expand('%:p:h'))
  end
  -- 写入文件
  vim.cmd('w')
end, { desc = 'file intelligence saving' })

-- space 行首行尾跳转
register('IntelliJump', function()
  local l_first, l_head = 1, vim.fn.len(vim.fn.getline('.')) - vim.fn.len(vim.fn.substitute(vim.fn.getline('.'), '^\\s*', '', 'G')) + 1
  local l_before = vim.fn.col('.')
  vim.cmd(l_before == l_first and l_first ~= l_head and 'norm! ^' or 'norm! $')
  local l_after = vim.fn.col('.')
  if l_before == l_after then
    vim.cmd('norm! 0')
  end
end, { desc = 'jump between head and tail' })

register('ReplaceWord', function(opts)
  local range = opts.args
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
end, { nargs = 1, desc = 'set highlight groups' })

return M
