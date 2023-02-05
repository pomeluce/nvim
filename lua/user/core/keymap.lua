local keymap = vim.api.nvim_set_keymap

-- 声明 leader 键
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- TODO: 基础配置
-- 基本键位映射
keymap('n', 's', '<nop>', {})
keymap('n', ';', ':', {})
keymap('v', ';', ':', {})
keymap('i', 'jk', '<esc>', { noremap = true, silent = true })
keymap('n', 'S', ':MagicSave<cr>', { noremap = true, silent = true })
keymap('n', 'Q', ':q!<cr>', { noremap = true, silent = true })
-- 粘贴之后不复制被粘贴的文本
keymap('v', 'p', '"_dhp', { noremap = true, silent = true })
-- 选中全文, 从当前选中的 { 复制全文
keymap('n', '<m-a>', 'ggVG', { noremap = true })
keymap('n', '<m-s>', 'vi{', { noremap = true })

-- TODO: 窗口相关设置
-- 设置水平分屏,并切换到下一个窗口
keymap('n', 'sv', ':vsp<cr><c-w>w', { noremap = true })
-- 设置垂直分屏,并切换到下一个窗口
keymap('n', 'sp', ':sp<cr><c-w>w', { noremap = true })
-- 关闭当前窗口
keymap('n', 'sc', ':close<cr>', { noremap = true })
-- 关闭其他窗口
keymap('n', 'so', ':only<cr>', { noremap = true })
-- 设置窗口跳转
keymap('n', '<c-h>', '<c-w>h', { noremap = true })
keymap('n', '<c-l>', '<c-w>l', { noremap = true })
keymap('n', '<c-k>', '<c-w>k', { noremap = true })
keymap('n', '<c-j>', '<c-w>j', { noremap = true })
keymap('n', '<c-Space>', '<c-w>w', { noremap = true })
-- 调整窗口尺寸 winnr() <= winner 判断是否为最后一个窗口
keymap('n', 's=', '<c-w>=', { noremap = true })
keymap('n', 's.', "winnr() <= winnr('$') - winnr() ? '<c-w>10>' : '<c-w>10<'", { noremap = true, expr = true })
keymap('n', 's,', "winnr() <= winnr('$') - winnr() ? '<c-w>10<' : '<c-w>10>'", { noremap = true, expr = true })
keymap('n', 'sj', "winnr() <= winnr('$') - winnr() ? '<c-w>10+' : '<c-w>10-'", { noremap = true, expr = true })
keymap('n', 'sk', "winnr() <= winnr('$') - winnr() ? '<c-w>10-' : '<c-w>10+'", { noremap = true, expr = true })
-- buffer 切换
keymap('n', 'ss', ':bn<cr>', { noremap = true, silent = true })
-- 关闭当前 buffer
keymap('n', '<leader>c', ':bw<cr>', { noremap = true, silent = true })
-- 前后切换 buffer
keymap('n', '<m-left>', '<esc>:bp<cr>', { noremap = true, silent = true })
keymap('n', '<m-right>', '<esc>:bn<cr>', { noremap = true, silent = true })
keymap('v', '<m-left>', '<esc>:bp<cr>', { noremap = true, silent = true })
keymap('v', '<m-right>', '<esc>:bn<cr>', { noremap = true, silent = true })
keymap('i', '<m-left>', '<esc>:bp<cr>', { noremap = true, silent = true })
keymap('i', '<m-right>', '<esc>:bn<cr>', { noremap = true, silent = true })

-- TODO: 代码跳转配置
-- 跳转到上次编辑位置
keymap('n', 'ga', "'.", { noremap = true, silent = true })
keymap('n', 'g;', '$a;<esc>', { noremap = true, silent = true })

-- TODO: 代码光标移动
-- 向上移动行
keymap('n', '<c-m-J>', ':m+<cr>', { noremap = true, silent = true })
keymap('i', '<c-m-J>', '<esc>:m+<cr>i', { noremap = true, silent = true })
keymap('v', '<c-m-J>', ":move '>+1<cr>gv", { noremap = true, silent = true })
-- 向下移动行
keymap('n', '<c-m-K>', ':m-2<cr>', { noremap = true, silent = true })
keymap('i', '<c-m-K>', '<esc>:m-2<cr>i', { noremap = true, silent = true })
keymap('v', '<c-m-K>', ":move '<-2<cr>gv", { noremap = true, silent = true })

-- TODO: 代码连续缩进
keymap('v', '<', '<gv', { noremap = true })
keymap('v', '>', '>gv', { noremap = true })
keymap('v', '<s-tab>', '<gv', { noremap = true })
keymap('v', '<tab>', '>gv', { noremap = true })

-- TODO: 其他配置
-- 全局替换 c-s = :%s/
keymap('n', '<c-s>', ':%s/\\v//gc<left><left><left><left>', { noremap = true })
keymap('v', '<c-s>', ':s/\\v//gc<left><left><left><left>', { noremap = true })
-- 打开高度为 10 的终端
keymap('n', 'tt', ':below 10sp | term<cr>a', { noremap = true, silent = true })
-- 取消搜索高亮
keymap('n', '<leader>nh', ':nohlsearch<cr>', { noremap = true, silent = true })
-- 重载配置文件
keymap('n', '<F2>', ':luafile %<cr>', { noremap = true, silent = true })
-- 行尾添加分号
keymap('n', '<leader>;', 'A;<esc>', { noremap = true, silent = true })
-- 代码折叠
keymap(
  'n',
  '--',
  "foldclosed(line('.')) == -1 ? ':MagicFold<cr>' : 'za'",
  { noremap = true, silent = true, expr = true }
)
keymap('v', '-', 'zf', { noremap = true })
-- space 行首行尾跳转
keymap('n', '<space>', ':MagicMove<cr>', { noremap = true, silent = true })
keymap('n', '0', '%', { noremap = true })
keymap('v', '0', '%', { noremap = true })
-- 驼峰转换
keymap('v', 'th', ':lua require("user.core.funcutil").toggleHump()<cr>', { noremap = true, silent = true })

--TODO: 插件快捷键
keymap('v', 'v', '<Plug>(expand_region_expand)', { silent = true })
keymap('v', 'V', '<Plug>(expand_region_shrink)', { silent = true })
-- 高亮当前光标下单词
keymap('n', 'ff', ":call InterestingWords('n')<cr>", { noremap = true, silent = true })
-- 取消高亮当前光标下单词
keymap('n', 'FF', ':call UncolorAllWords()<cr>', { noremap = true, silent = true })
-- 单词导航
keymap('n', 'n', ":call WordNavigation('forward')<cr>", { noremap = true, silent = true })
keymap('n', 'N', ":call WordNavigation('backward')<cr>", { noremap = true, silent = true })
keymap('n', '<leader>ss', ':SymbolsOutline<CR>', { noremap = true, silent = true })
-- 代码格式化
keymap('n', '<leader>fm', ':Format<CR>', { noremap = true, silent = true })
keymap('v', '<leader>fm', ':Format<CR>', { noremap = true, silent = true })
keymap('i', '<Right>', 'copilot#Accept("<Right>")', { script = true, silent = true, expr = true })
-- 根据文件类型启动浮动终端执行当前文件
keymap('n', '<F5>', ':lua require("user.plugins.vim-floaterm").runFile()<cr>', { noremap = true, silent = true })
keymap('i', '<F5>', '<esc>:lua require("user.plugins.vim-floaterm").runFile()<cr>', { noremap = true, silent = true })
keymap(
  't',
  '<F5>',
  "&ft == \"floaterm\" ? printf('<c-\\><c-n>:FloatermHide<cr>%s', floaterm#terminal#get_bufnr('RUN') == bufnr('%') ? '' : '<F5>') : '<F5>'",
  { silent = true, expr = true }
)
-- 全局文本搜索(yay -S the_silver_searcher fd bat)
keymap('n', '<leader>ft', ':Ag<cr>', { noremap = true, silent = true })
-- 文件列表查找
keymap('n', '<leader>ff', ':Files<cr>', { noremap = true, silent = true })
-- 当前文本内容查找
keymap('n', '<leader>fw', ':BLines<cr>', { noremap = true, silent = true })
-- git 文件查找
keymap('n', '<leader>fg', ':GFiles?<cr>', { noremap = true, silent = true })
-- 查看历史文件
keymap('n', '<leader>fh', ':FHistory<cr>', { noremap = true, silent = true })
keymap('n', '<leader>rt', '<cmd>lua require("spectre").open()<CR>', { noremap = true, silent = true })
keymap(
  'v',
  '<leader>rt',
  '<esc>:lua require("spectre").open_visual({ select_word=true })<CR>',
  { noremap = true, silent = true }
)
-- 语法高亮
keymap('n', 'H', ':TSHighlightCapturesUnderCursor<CR>', { noremap = true, silent = true })
-- 刷新语法高亮
keymap('n', 'R', ':write | edit | TSBufEnable highlight<CR>', { silent = true, noremap = true })
-- 打开文件树
keymap(
  'n',
  'T',
  'g:nvim_tree_firsttime != 1 ? ":NvimTreeToggle<cr>" : ":let g:nvim_tree_firsttime = 0<cr>:NvimTreeToggle $PWD<cr>"',
  { noremap = true, silent = true, expr = true }
)
-- dashboard 封面快捷键
keymap('n', '<leader>sp', ':NvimTreeOpen /home/developcode/Web/<cr>', { noremap = true, silent = true })
keymap('n', '<leader>es', ':edit $MYVIMRC<cr>', { noremap = true, silent = true })
keymap('n', '<leader>ek', ':edit $HOME/.config/nvim/lua/user/core/keymap.lua<cr>', { noremap = true, silent = true })
-- vsnip 快捷键设置
keymap('i', '<tab>', 'vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<tab>"', { expr = true, noremap = true })
keymap('s', '<tab>', 'vsnip#jumpable(1) ? "<Plug>(vsnip-jump-next)" : "<tab>"', { expr = true, noremap = true })
keymap('i', '<s-tab>', 'vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)" : "<s-tab>"', { expr = true, noremap = true })
keymap('s', '<s-tab>', 'vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)" : "<s-tab>"', { expr = true, noremap = true })
-- git 提交历史查看
keymap('n', 'C', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>', { noremap = true, silent = true })
-- translator 翻译
keymap('n', '<leader>tr', ':TranslateW<CR>', { noremap = true, silent = true })
keymap('v', '<leader>tr', ':TranslateWV<CR>', { noremap = true, silent = true })
