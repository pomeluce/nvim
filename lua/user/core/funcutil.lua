local M = {}
local autocmd = vim.api.nvim_create_autocmd

-- 文件保存
function M.magicSave()
  -- 如果目录不存在, 创建目录
  if vim.fn.empty(vim.fn.glob(vim.fn.expand('%:p:h'))) == 1 then
    vim.fn.system('mkdir -p ' .. vim.fn.expand('%:p:h'))
  end
  -- 如果文件不可写, 使用 sudo 来写入
  if vim.bo.buftype == 'acwrite' then
    vim.cmd('w !sudo tee > /dev/null %')
  else
    vim.cmd('w')
  end
end

vim.cmd('com! MagicSave lua require("user.core.funcutil").magicSave()')

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

-- 折叠方法
function M.magicFold()
  local l_line = vim.fn.trim(vim.fn.getline('.'))
  if l_line == '' then
    return
  end
  local l_up, l_down = 0, 0
  if l_line:sub(1, 1) == '}' then
    vim.cmd('norm! ^%')
    l_up = vim.fn.line('.')
    vim.cmd('norm! %')
  end
  if l_line:sub(-1) == '{' then
    vim.cmd('norm! $%')
    l_down = vim.fn.line('.')
    vim.cmd('norm! %')
  end
  local ok = pcall(function()
    if l_up ~= 0 and l_down ~= 0 then
      vim.cmd('norm! ' .. l_up .. 'GV' .. l_down .. 'Gzf')
    elseif l_up ~= 0 then
      vim.cmd('norm! V' .. l_up .. 'Gzf')
    elseif l_down ~= 0 then
      vim.cmd('norm! V' .. l_down .. 'Gzf')
    else
      vim.cmd('norm! za')
    end
  end)
  if not ok then
    vim.cmd('redraw!')
  end
end

vim.cmd('com! MagicFold lua require("user.core.funcutil").magicFold()')

-- space 行首行尾跳转
function M.magicMove()
  local l_first, l_head =
    1, vim.fn.len(vim.fn.getline('.')) - vim.fn.len(vim.fn.substitute(vim.fn.getline('.'), '^\\s*', '', 'G')) + 1
  local l_before = vim.fn.col('.')
  vim.cmd(l_before == l_first and l_first ~= l_head and 'norm! ^' or 'norm! $')
  local l_after = vim.fn.col('.')
  if l_before == l_after then
    vim.cmd('norm! 0')
  end
end

vim.cmd('com! MagicMove lua require("user.core.funcutil").magicMove()')

-- 驼峰转换
vim.cmd('com! ToggleHump lua require("user.core.funcutil").toggleHump()')

function M.toggleHump()
  local l, c1, c2 = vim.fn.line('.'), vim.fn.col("'<"), vim.fn.col("'>")
  local line = vim.fn.getline(l)
  local w = line:sub(c1, c2)
  w = w:find('_') and w:gsub('_(.)', function(c)
    return c:upper()
  end) or w:gsub('^%u', function(c)
    return c:lower()
  end):gsub('%u', function(c)
    return '_' .. c:lower()
  end)
  vim.fn.setbufline(
    '%',
    l,
    string.format('%s%s%s', c1 == 1 and '' or line:sub(1, c1 - 1), w, c2 == 1 and '' or line:sub(c2 + 1))
  )
  vim.fn.cursor(l, c1)
end

return M
