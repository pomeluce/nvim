local G = require('G')

-- 快捷键配置
G.map({
  -- TODO: 基础配置
  -- 基本键位映射
  { 'n', 's', '<nop>', {} },
  { 'n', ';', ':', {} },
  { 'v', ';', ':', {} },
  { 'i', 'jk', '<esc>', { noremap = true, silent = true } },
  { 'n', 'S', ':MagicSave<cr>', { noremap = true, silent = true } },
  { 'n', 'Q', ':q!<cr>', { noremap = true, silent = true } },
  -- 粘贴之后不复制被粘贴的文本
  { 'v', 'p', '"_dhp', { noremap = true, silent = true } },
  -- 选中全文, 从当前选中的 { 复制全文
  { 'n', '<m-a>', 'ggVG', { noremap = true } },
  { 'n', '<m-s>', 'vi{', { noremap = true } },
  -- TODO: 窗口相关设置
  -- 设置水平分屏,并切换到下一个窗口
  { 'n', 'sv', ':vsp<cr><c-w>w', { noremap = true } },
  -- 设置垂直分屏,并切换到下一个窗口
  { 'n', 'sp', ':sp<cr><c-w>w', { noremap = true } },
  -- 关闭当前窗口
  { 'n', 'sc', ':close<cr>', { noremap = true } },
  -- 关闭其他窗口
  { 'n', 'so', ':only<cr>', { noremap = true } },
  -- 设置窗口跳转
  { 'n', '<c-h>', '<c-w>h', { noremap = true } },
  { 'n', '<c-l>', '<c-w>l', { noremap = true } },
  { 'n', '<c-k>', '<c-w>k', { noremap = true } },
  { 'n', '<c-j>', '<c-w>j', { noremap = true } },
  { 'n', '<c-Space>', '<c-w>w', { noremap = true } },
  -- 调整窗口尺寸 winnr() <= winner 判断是否为最后一个窗口
  { 'n', 's=', '<c-w>=', { noremap = true } },
  { 'n', 's.', "winnr() <= winnr('$') - winnr() ? '<c-w>10>' : '<c-w>10<'", { noremap = true, expr = true } },
  { 'n', 's,', "winnr() <= winnr('$') - winnr() ? '<c-w>10<' : '<c-w>10>'", { noremap = true, expr = true } },
  { 'n', 'sj', "winnr() <= winnr('$') - winnr() ? '<c-w>10+' : '<c-w>10-'", { noremap = true, expr = true } },
  { 'n', 'sk', "winnr() <= winnr('$') - winnr() ? '<c-w>10-' : '<c-w>10+'", { noremap = true, expr = true } },
  -- buffer 切换
  { 'n', 'ss', ':bn<cr>', { noremap = true, silent = true } },
  -- 关闭当前 buffer
  { 'n', '<leader>c', ':bw<cr>', { noremap = true, silent = true } },
  -- 前后切换 buffer
  { 'n', '<m-left>', '<esc>:bp<cr>', { noremap = true, silent = true } },
  { 'n', '<m-right>', '<esc>:bn<cr>', { noremap = true, silent = true } },
  { 'v', '<m-left>', '<esc>:bp<cr>', { noremap = true, silent = true } },
  { 'v', '<m-right>', '<esc>:bn<cr>', { noremap = true, silent = true } },
  { 'i', '<m-left>', '<esc>:bp<cr>', { noremap = true, silent = true } },
  { 'i', '<m-right>', '<esc>:bn<cr>', { noremap = true, silent = true } },
  -- TODO: 代码跳转配置
  -- 跳转到上次编辑位置
  { 'n', 'ga', "'.", { noremap = true, silent = true } },
  -- TODO: 代码光标移动
  -- 向上移动行
  { 'n', '<c-m-J>', ':m+<cr>', { noremap = true, silent = true } },
  { 'i', '<c-m-J>', '<esc>:m+<cr>i', { noremap = true, silent = true } },
  { 'v', '<c-m-J>', ':move \'>+1<cr>gv', { noremap = true, silent = true } },
  -- 向下移动行
  { 'n', '<c-m-K>', ':m-2<cr>', { noremap = true, silent = true } },
  { 'i', '<c-m-K>', '<esc>:m-2<cr>i', { noremap = true, silent = true } },
  { 'v', '<c-m-K>', ':move \'<-2<cr>gv', { noremap = true, silent = true } },
  -- TODO: 代码连续缩进
  { 'v', '<', '<gv', { noremap = true } },
  { 'v', '>', '>gv', { noremap = true } },
  { 'v', '<s-tab>', '<gv', { noremap = true } },
  { 'v', '<tab>', '>gv', { noremap = true } },
  -- TODO: 其他配置
  -- 全局替换 c-s = :%s/
  { 'n', '<c-s>', ':%s/\\v//gc<left><left><left><left>', { noremap = true } },
  { 'v', '<c-s>', ':s/\\v//gc<left><left><left><left>', { noremap = true } },
  -- 打开高度为 10 的终端
  { 'n', 'tt', ':below 10sp | term<cr>a', { noremap = true, silent = true } },
  -- 取消搜索高亮
  { 'n', '<leader>nh', ':nohlsearch<cr>', { noremap = true, silent = true } },
  -- 重载配置文件
  { 'n', '<F2>', ':luafile %<cr>', { noremap = true, silent = true } },
  -- 行尾添加分号
  { 'n', '<leader>;', 'A;<esc>', { noremap = true, silent = true } },
  -- 代码折叠
  { 'n', '--', "foldclosed(line('.')) == -1 ? ':MagicFold<cr>' : 'za'",
    { noremap = true, silent = true, expr = true } },
  { 'v', '-', 'zf', { noremap = true } },
  -- space 行首行尾跳转
  { 'n', '<space>', ':MagicMove<cr>', { noremap = true, silent = true } },
  { 'n', '0', '%', { noremap = true } },
  { 'v', '0', '%', { noremap = true } },
  -- 驼峰转换
  { 'v', 'th', ':lua require("funcutil").toggleHump()<cr>', { noremap = true, silent = true } },
})
