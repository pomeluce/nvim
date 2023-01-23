local G = require('G')

local autoGroup = G.api.nvim_create_augroup('autoGroup', { clear = true })
local autocmd = G.api.nvim_create_autocmd

-- 修改 lua/packinit.lua 自动更新插件
autocmd("BufWritePost", {
  group = autoGroup,
  callback = function()
    if G.fn.expand("<afile>") == "packinit.lua" then
      G.cmd('source packinit.lua')
      G.cmd('PackerSync')
    end
  end,
})

-- 用 o 换行不要延续注释
autocmd("BufEnter", {
  group = autoGroup,
  pattern = "*",
  callback = function()
    G.opt.formatoptions = G.opt.formatoptions
        - "o" -- O 和 o, 不要延续注释
        + "r" -- 回车延续注释
  end,
})

-- 光标回到上次位置
autocmd("BufReadPost", {
  group = autoGroup,
  pattern = "*",
  callback = function()
    if G.fn.line("'\"") > 1 and G.fn.line("'\"") <= G.fn.line("$") then
      G.cmd("normal! g`\"")
    end
  end,
})

autocmd("BufEnter", {
  group = autoGroup,
  pattern = "*",
  callback = function()
    if G.fn.getbufvar(0, "&buftype") == '' and G.fn.getbufvar(0, "&readonly") == 1 then
      G.cmd([[
        setlocal buftype=acwrite
        setlocal noreadonly
      ]])
    end
  end
})

-- 自动保存折叠信息
autocmd("FileType", {
  group = autoGroup,
  pattern = "*",
  callback = function()
    pcall(G.cmd, [[ silent! mkview ]])
  end
})
autocmd("BufLeave,BufWinEnter", {
  group = autoGroup,
  pattern = "*",
  callback = function()
    pcall(G.cmd, [[ silent! loadview ]])
  end
})
