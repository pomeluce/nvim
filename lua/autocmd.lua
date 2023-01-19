local G = require('G')

-- 光标回到上次位置
G.cmd([[ au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif ]])

G.cmd([[ au BufEnter * if &buftype == '' && &readonly == 1 | set buftype=acwrite | set noreadonly | endif ]])
