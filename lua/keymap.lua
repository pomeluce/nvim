local G = require('G')

-- [[
-- au 定义自动命令
-- bufEnter 进入缓冲区后。可用来设定有关文件类型的选项。也在开始编辑缓冲区时执行，它发生在 BufReadPost自动命令之后
-- acwrite 缓冲区总是用 BufWriteCmd 自动命令写回
-- ]]
G.cmd([[au BufEnter * if &buftype == '' && &readonly == 1 | set buftype=acwrite | set noreadonly | endif]])
-- 文件保存
G.cmd([[
func MagicSave()
    " If the directory is not exited, create it
    if empty(glob(expand("%:p:h")))
        call system("mkdir -p " . expand("%:p:h"))
    endif
    " If the file is not writable, use sudo to write it
    if &buftype == 'acwrite'
        w !sudo tee > /dev/null %
    else
        w
    endif
endf
]])

-- 快捷键配置
G.map({
  -- TODO: 基础配置
  -- 基本键位映射
  { 'n', 's', '<nop>', {} }, 
  { 'n', ';', ':', {} }, 
  { 'v', ';', ':', {} }, 
  { 'i', 'jk', '<esc>', G.opt },
  { 'n', 'S', ':call MagicSave()<cr>', G.opt },
  { 'n', 'Q', ':q!<cr>', G.opt },
  -- 粘贴之后不复制被粘贴的文本
  { 'v', 'p', '"_dhp', G.opt }, 
  -- 选中全文, 从当前选中的 { 复制全文
  { 'n', '<m-a>', 'ggVG', G.opt_nore },
  { 'n', '<m-s>', 'vi{', G.opt_nore },
  -- TODO: 窗口相关设置
  -- 设置水平分屏,并切换到下一个窗口
  { 'n', 'sv', ':vsp<cr><c-w>w', G.opt_nore },
  -- 设置垂直分屏,并切换到下一个窗口
  { 'n', 'sp', ':sp<cr><c-w>w', G.opt_nore },
  -- 关闭当前窗口
  { 'n', 'sc', ':close<cr>', G.opt_nore },
  -- 关闭其他窗口
  { 'n', 'so', ':only<cr>', G.opt_nore },
  -- 设置窗口跳转
  { 'n', '<c-h>', '<c-w>h', G.opt_nore },
  { 'n', '<c-l>', '<c-w>l', G.opt_nore },
  { 'n', '<c-k>', '<c-w>k', G.opt_nore },
  { 'n', '<c-j>', '<c-w>j', G.opt_nore },
  { 'n', '<c-Space>', '<c-w>w', G.opt_nore },
  -- 调整窗口尺寸 winnr() <= winner 判断是否为最后一个窗口
  { 'n', 's=',  '<c-w>=', G.opt_nore },
  { 'n', 's.', "winnr() <= winnr('$') - winnr() ? '<c-w>10>' : '<c-w>10<'", G.opt_expr },
  { 'n', 's,', "winnr() <= winnr('$') - winnr() ? '<c-w>10<' : '<c-w>10>'", G.opt_expr },
  { 'n', 'sj', "winnr() <= winnr('$') - winnr() ? '<c-w>10+' : '<c-w>10-'", G.opt_expr },
  { 'n', 'sk', "winnr() <= winnr('$') - winnr() ? '<c-w>10-' : '<c-w>10+'", G.opt_expr },
  -- buffer 切换
  { 'n', 'ss', ':bn<cr>', G.opt },
  -- 关闭当前 buffer
  { 'n', '<leader>c', ':bw<cr>', G.opt },
  -- 前后切换 buffer
  { 'n', '<m-left>',    '<esc>:bp<cr>', G.opt },
  { 'n', '<m-right>',   '<esc>:bn<cr>', G.opt },
  { 'v', '<m-left>',    '<esc>:bp<cr>', G.opt },
  { 'v', '<m-right>',   '<esc>:bn<cr>', G.opt },
  { 'i', '<m-left>',    '<esc>:bp<cr>', G.opt },
  { 'i', '<m-right>',   '<esc>:bn<cr>', G.opt },
  -- TODO: 代码跳转配置
  -- 跳转到上次编辑位置
  { 'n', 'ga', "'.", G.opt },
  -- TODO: 代码光标移动
  -- 向上移动行 
  { 'n', '<c-m-J>', ':m+<cr>', G.opt },
  { 'i', '<c-m-J>', '<esc>:m+<cr>i', G.opt },
  { 'v', '<c-m-J>', ':move \'>+1<cr>gv', G.opt },
  -- 向下移动行 
  { 'n', '<c-m-K>', ':m-2<cr>', G.opt },
  { 'i', '<c-m-K>', '<esc>:m-2<cr>i', G.opt },
  { 'v', '<c-m-K>', ':move \'<-2<cr>gv', G.opt },
  -- TODO: 代码连续缩进
  { 'v', '<', '<gv', G.opt_nore },
  { 'v', '>', '>gv', G.opt_nore },
  { 'v', '<s-tab>', '<gv', G.opt_nore },
  { 'v', '<tab>', '>gv', G.opt_nore },
  -- TODO: 其他配置
  -- 打开高度为 10 的终端
  { 'n', 'tt', ':below 10sp | term<cr>a', G.opt },
  -- 取消搜索高亮
  { 'n', '<leader>nh', ':nohlsearch<cr>', G.opt},
})

-- 重设tab长度
G.cmd('command! -nargs=* SetTab call SwitchTab(<q-args>)')
G.cmd([[
    fun! SwitchTab(tab_len)
        if !empty(a:tab_len)
            let [&shiftwidth, &softtabstop, &tabstop] = [a:tab_len, a:tab_len, a:tab_len]
        else
            let l:tab_len = input('input shiftwidth: ')
            if !empty(l:tab_len)
                let [&shiftwidth, &softtabstop, &tabstop] = [l:tab_len, l:tab_len, l:tab_len]
            endif
        endif
        redraw!
        echo printf('shiftwidth: %d', &shiftwidth)
    endf
]])

-- 折叠
G.map({
  { 'n', '--', "foldclosed(line('.')) == -1 ? ':call MagicFold()<cr>' : 'za'", G.opts },
  { 'v', '-',  'zf', G.opt_nore },
})
G.cmd([[
    fun! MagicFold()
        let l:line = trim(getline('.'))
        if l:line == '' | return | endif
        let [l:up, l:down] = [0, 0]
        if l:line[0] == '}'
            exe 'norm! ^%'
            let l:up = line('.')
            exe 'norm! %'
        endif
        if l:line[len(l:line) - 1] == '{'
            exe 'norm! $%'
            let l:down = line('.')
            exe 'norm! %'
        endif
        try
            if l:up != 0 && l:down != 0
                exe 'norm! ' . l:up . 'GV' . l:down . 'Gzf'
            elseif l:up != 0
                exe 'norm! V' . l:up . 'Gzf'
            elseif l:down != 0
                exe 'norm! V' . l:down . 'Gzf'
            else
                exe 'norm! za'
            endif
        catch
            redraw!
        endtry
    endf
]])

-- space 行首行尾跳转
G.map({
    { 'n', '<space>', ':call MagicMove()<cr>', G.opt },
    { 'n', '0', '%', G.opt_nore },
    { 'v', '0', '%', G.opt_nore },
})
G.cmd([[
    fun! MagicMove()
        let [l:first, l:head] = [1, len(getline('.')) - len(substitute(getline('.'), '^\s*', '', 'G')) + 1]
        let l:before = col('.')
        exe l:before == l:first && l:first != l:head ? 'norm! ^' : 'norm! $'
        let l:after = col('.')
        if l:before == l:after
            exe 'norm! 0'
        endif
    endf
]])

-- 驼峰转换
G.map({ 
  { 'v', 'th', ':call ToggleHump()<CR>', G.opt }, 
})
G.cmd([[
    fun! ToggleHump()
        let [l, c1, c2] = [line('.'), col("'<"), col("'>")]
        let line = getline(l)
        let w = line[c1 - 1 : c2 - 2]
        let w = w =~ '_' ? substitute(w, '\v_(.)', '\u\1', 'g') : substitute(substitute(w, '\v^(\u)', '\l\1', 'g'), '\v(\u)', '_\l\1', 'g')
        call setbufline('%', l, printf('%s%s%s', c1 == 1 ? '' : line[:c1-2], w, c2 == 1 ? '' : line[c2-1:]))
        call cursor(l, c1)
    endf
]])
