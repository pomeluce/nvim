local M = {}

-- 文件保存
function M.save()
  -- 如果目录不存在, 创建目录
  if vim.fn.empty(vim.fn.glob(vim.fn.expand('%:p:h'))) == 1 then
    vim.fn.system('mkdir -p ' .. vim.fn.expand('%:p:h'))
  end
  -- 如果文件不可写, 使用 sudo 来写入
  -- if vim.bo.buftype == 'acwrite' then
  --   local pass = vim.fn.input('Enter your password: ')
  --   vim.cmd('w !echo ' .. pass .. ' | sudo -S tee > /dev/null %')
  -- else
  -- 保存工作会话
  vim.cmd('SessionSave')
  -- 写入文件
  vim.cmd('w')
  -- end
end

vim.cmd('com! RifySave lua require("user.core.funcutil").save()')

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

vim.cmd('com! RifyFold lua require("user.core.funcutil").fold()')

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

vim.cmd('com! RifyJump lua require("user.core.funcutil").jump()')

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

return M
