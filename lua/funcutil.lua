local G = require('G')
local M = {}

-- 文件保存
function M.magicSave()
  -- 如果目录不存在, 创建目录
  if G.fn.empty(G.fn.glob(G.fn.expand('%:p:h'))) == 1 then
    G.fn.system('mkdir -p ' .. G.fn.expand('%:p:h'))
  end
  -- 如果文件不可写, 使用 sudo 来写入
  if G.bo.buftype == 'acwrite' then
    G.cmd('w !sudo tee > /dev/null %')
  else
    G.cmd('w')
  end
end

G.cmd('com! MagicSave lua require("funcutil").magicSave()')

-- 重设tab长度
function M.switchTab(tab_len)
  if G.fn.empty(tab_len) == 0 then
    G.o.shiftwidth = tonumber(l_tab_len)
    G.o.softtabstop = tonumber(l_tab_len)
    G.o.tabstop = tonumber(l_tab_len)
  else
    local l_tab_len = G.fn.input('input shiftwidth: ')
    if G.fn.empty(l_tab_len) == 0 then
      G.o.shiftwidth = tonumber(l_tab_len)
      G.o.softtabstop = tonumber(l_tab_len)
      G.o.tabstop = tonumber(l_tab_len)
    end
  end
  G.cmd('redraw!')
  print('shiftwidth: ' .. G.o.shiftwidth)
end

G.cmd('command! -nargs=* SetTab lua require("funcutil").switchTab(<q-args>)')

-- 折叠方法
function M.magicFold()
  local l_line = G.fn.trim(G.fn.getline('.'))
  if l_line == '' then return end
  local l_up, l_down = 0, 0
  if l_line:sub(1, 1) == '}' then
    G.cmd('norm! ^%')
    l_up = G.fn.line('.')
    G.cmd('norm! %')
  end
  if l_line:sub(-1) == '{' then
    G.cmd('norm! $%')
    l_down = G.fn.line('.')
    G.cmd('norm! %')
  end
  local ok = pcall(function()
    if l_up ~= 0 and l_down ~= 0 then
      G.cmd('norm! ' .. l_up .. 'GV' .. l_down .. 'Gzf')
    elseif l_up ~= 0 then
      G.cmd('norm! V' .. l_up .. 'Gzf')
    elseif l_down ~= 0 then
      G.cmd('norm! V' .. l_down .. 'Gzf')
    else
      G.cmd('norm! za')
    end
  end)
  if not ok then
    G.cmd('redraw!')
  end
end

G.cmd('com! MagicFold lua require("funcutil").magicFold()')

-- space 行首行尾跳转
function M.magicMove()
  local l_first, l_head = 1,
      G.fn.len(G.fn.getline('.')) - G.fn.len(G.fn.substitute(G.fn.getline('.'), '^\\s*', '', 'G')) + 1
  local l_before = G.fn.col('.')
  G.cmd(l_before == l_first and l_first ~= l_head and 'norm! ^' or 'norm! $')
  local l_after = G.fn.col('.')
  if l_before == l_after then
    G.cmd('norm! 0')
  end
end

G.cmd('com! MagicMove lua require("funcutil").magicMove()')


-- 驼峰转换
G.cmd('com! ToggleHump lua require("funcutil").toggleHump()')
function M.toggleHump()
  local l_l, l_c1, l_c2 = G.fn.line('.'), G.fn.col("'<"), G.fn.col("'>")
  local l_line = G.fn.getline(l_l)
  local l_w = l_line:sub(l_c1 - 1, l_c2 - 2)
  local l_w = l_w:find('_') and l_w:gsub('_(.)', function(c) return c:upper() end) or
      l_w:gsub('^%u', function(c) return c:lower() end):gsub('%u', function(c) return '_' .. c:lower() end)
  G.fn.setbufline('%', l_l,
    string.format('%s%s%s', l_c1 == 1 and '' or l_line:sub(1, l_c1 - 2), l_w, l_c2 == 1 and '' or l_line:sub(l_c2)))
  G.fn.cursor(l_l, l_c1)
end

return M
