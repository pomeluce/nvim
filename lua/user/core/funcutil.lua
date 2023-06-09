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

-- 代码折叠
function M.magicFold()
  local spacetext = ("        "):sub(0, vim.opt.shiftwidth:get())
  local line = vim.fn.getline(vim.v.foldstart):gsub("\t", spacetext)
  local folded = vim.v.foldend - vim.v.foldstart + 1
  local findresult = line:find('%S')
  if not findresult then return '+ folded ' .. folded .. ' lines ' end
  local empty = findresult - 1
  local funcs = {
    [0] = function(_) return '' .. line end,
    [1] = function(_) return '+' .. line:sub(2) end,
    [2] = function(_) return '+ ' .. line:sub(3) end,
    [-1] = function(c)
      local result = ' ' .. line:sub(c + 1)
      local foldednumlen = #tostring(folded)
      for _ = 1, c - 2 - foldednumlen do result = '-' .. result end
      return '+' .. folded .. result
    end,
  }
  return funcs[empty <= 2 and empty or -1](empty) .. ' folded ' .. folded .. ' lines '
end

vim.cmd('com! MagicFold lua require("user.core.funcutil").magicFold()')

-- space 行首行尾跳转
function M.magicMove()
  local l_first, l_head = 1,
      vim.fn.len(vim.fn.getline('.')) - vim.fn.len(vim.fn.substitute(vim.fn.getline('.'), '^\\s*', '', 'G')) + 1
  local l_before = vim.fn.col('.')
  vim.cmd(l_before == l_first and l_first ~= l_head and 'norm! ^' or 'norm! $')
  local l_after = vim.fn.col('.')
  if l_before == l_after then
    vim.cmd('norm! 0')
  end
end

vim.cmd('com! MagicMove lua require("user.core.funcutil").magicMove()')

-- 驼峰转换
function M.toggleHump(upperCase)
  vim.fn.execute('normal! gv"tx')
  local w = vim.fn.getreg('t')
  local toHump = w:find('_') ~= nil
  if toHump then
    w = w:gsub('_(%w)', function(c) return c:upper() end)
  else
    w = w:gsub('(%u)', function(c) return '_' .. c:lower() end)
  end
  if w:sub(1, 1) == '_' then w = w:sub(2) end
  if upperCase then w = w:sub(1, 1):upper() .. w:sub(2) end
  vim.fn.setreg('t', w)
  vim.fn.execute('normal! "tP')
end

vim.cmd('com! ToggleHump lua require("user.core.funcutil").toggleHump()')

return M
