local map = vim.keymap.set

-- 保存并重新加载配置
map('n', '<leader>U', '<cmd>update<cr> <cmd>source<cr>', { desc = 'Reload config file' })
-- 重新加载 Neovim
map('n', '<leader>R', '<cmd>restart<cr>', { desc = 'Restart Neovim' })
-- 代码补全
map('i', '<c-space>', '<c-x><c-o>', { desc = 'Trigger completion' })
-- terminal 切换 visual 模式
map('t', '<c-space>', '<c-\\><c-n>', { desc = 'Toggle visual mode in floaterm' })
-- 释放替换键
map('n', 's', '<nop>', { desc = 'Released substitute key' })
-- 代码保存
map('n', 'S', '<cmd>IntelliSave<cr>', { desc = 'Intelli save file' })
-- 强制退出
map('n', 'Q', '<cmd>q!<cr>', { desc = 'Force quit' })
-- 进入命令模式
map({ 'n', 'v' }, ';', ':', { desc = 'Toggle mode for command' })
-- 重写上下移动
map({ 'n', 'x', 'v' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Move cursor down', expr = true })
map({ 'n', 'x', 'v' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Move cursor up', expr = true })

-- 设置删除后不复制删除后的文本
map('v', 'c', '"_c', { desc = 'Delete without copy to register' })
-- 粘贴之后不复制被粘贴的文本
map('v', 'p', '"_dhp', { desc = 'Paste without copy to register' })

-- 选中全文
map('n', '<m-a>', 'ggVG', { desc = 'Select all text' })
-- 从当前选中的 { 复制全文
map('n', '<m-s>', 'vi{', { desc = 'Select brackets text' })

-- 全局替换 c-s = :%s/
map('n', '<c-s>', '<cmd>ReplaceWord %<cr>', { desc = 'Buffer literal repalce' })
map('v', '<c-s>', "<esc><cmd>ReplaceWord '<,'><cr>", { desc = 'Visual literal repalce' })

-- 取消搜索高亮
map('n', '<esc>', '<cmd>nohlsearch<cr>', { desc = 'Disable search highlighting' })

-- 设置水平分屏, 并切换到下一个窗口
map('n', 'sv', '<cmd>vsp<cr><c-w>w', { desc = 'Split horizontal window' })

-- 设置垂直分屏, 并切换到下一个窗口
map('n', 'sp', '<cmd>sp<cr><c-w>w', { desc = 'Split vertical window' })

-- 关闭当前窗口
map('n', 'sc', '<cmd>close<cr>', { desc = 'Close current window' })

-- 关闭其他窗口
map('n', 'so', '<cmd>only<cr>', { desc = 'Close other window' })

-- 设置 buffer 跳转
map('n', '<c-h>', '<c-w>h', { desc = 'Jump to left buffer' })
map('n', '<c-l>', '<c-w>l', { desc = 'Jump to right buffer' })
map('n', '<c-k>', '<c-w>k', { desc = 'Jump to top buffer' })
map('n', '<c-j>', '<c-w>j', { desc = 'Jump to bottom buffer' })

-- 调整窗口尺寸
map('n', 's=', '<c-w>=', { desc = 'Resize all window same size' })
map('n', 's.', "winnr() <= winnr('$') - winnr() ? '<c-w>10>' : '<c-w>10<'", { desc = 'Extend window to right', expr = true })
map('n', 's,', "winnr() <= winnr('$') - winnr() ? '<c-w>10<' : '<c-w>10>'", { desc = 'Extend window to left', expr = true })
map('n', 'sj', "winnr() <= winnr('$') - winnr() ? '<c-w>10+' : '<c-w>10-'", { desc = 'Extend window to top', expr = true })
map('n', 'sk', "winnr() <= winnr('$') - winnr() ? '<c-w>10-' : '<c-w>10+'", { desc = 'Extent window to bottom', expr = true })

-- flash 代码跳转
local function code_jump()
  require('flash').jump({ search = { mode = function(str) return '\\<' .. str end } })
end
map({ 'n', 'x', 'o' }, 's', code_jump, { desc = 'Flash code jump' })
-- flash 代码选中
map({ 'n', 'x', 'o' }, 'fs', function() require('flash').treesitter() end, { desc = 'Flash code select' })
-- flash 跳转复制
map('o', 'r', function() require('flash').remote() end, { desc = 'Flash code jump and copy' })
-- flash 选择复制
map({ 'o', 'x' }, 'fr', function() require('flash').treesitter_search() end, { desc = 'Flash code select and copy' })

-- 插入模式下移动光标
map('i', '<m-h>', '<left>', { desc = 'Move cursor in insert mode' })
map('i', '<m-l>', '<right>', { desc = 'Move cursor in insert mode' })
map('i', '<m-k>', '<up>', { desc = 'Move cursor in insert mode' })
map('i', '<m-j>', '<down>', { desc = 'Move cursor in insert mode' })

-- 向上移动行
map('n', '<c-m-J>', '<cmd>m+<cr>', { desc = 'Move current line to up' })
map('i', '<c-m-J>', '<esc><cmd>m+<cr>i', { desc = 'Move current line to up' })
map('v', '<c-m-J>', "<cmd>move '>+1<cr>gv", { desc = 'Move current line to up' })
map('v', 'J', "<cmd>move '>+1<cr>gv", { desc = 'Move current line to up' })

-- 向下移动行
map('n', '<c-m-K>', '<cmd>m-2<cr>', { desc = 'Move current line to down' })
map('i', '<c-m-K>', '<esc><cmd>m-2<cr>i', { desc = 'Move current line to down' })
map('v', '<c-m-K>', "<cmd>move '<-2<cr>gv", { desc = 'Move current line to down' })
map('v', 'K', "<cmd>move '<-2<cr>gv", { desc = 'Move current line to down' })

-- 代码连续缩进
map('v', '<', '<gv', { desc = 'Indent to left' })
map('v', '>', '>gv', { desc = 'Indent to right' })
map('v', '<s-tab>', '<gv', { desc = 'Indent to left' })
map('v', '<tab>', '>gv', { desc = 'indent to right' })

-- 跳转到上次编辑位置
map('n', 'ga', '`.', { desc = 'Jump cursor to last edit position' })

-- 行尾添加分号
map('n', 'g;', '$a;<esc>', { desc = 'Add semicolon for endline' })

local function toggle_nvim_tree()
  if vim.g.nvim_tree_firsttime ~= 1 then
    vim.cmd('NvimTreeToggle')
  else
    vim.g.nvim_tree_firsttime = 0
    vim.cmd('NvimTreeToggle ' .. vim.fn.getcwd())
  end
end
map('n', 'T', toggle_nvim_tree, { desc = 'Toggle file tree' })

-- 代码折叠
map({ 'n', 'v' }, 'zz', 'za', { desc = 'Toggle fold under cursor' })

-- 查看语法高亮
map('n', 'H', '<cmd>Inspect<cr>', { desc = 'Inspect syntax highlight group under cursor' })

-- 查看当前行 git 提交信息
map('n', 'C', '<cmd>Gitsigns blame_line full=true<cr>', { desc = 'Show current line git blame' })
-- 切换当前行 git 提交记录信息
map('n', '\\g', '<cmd>Gitsigns toggle_current_line_blame<cr>', { desc = 'Toggle show blame line' })

-- 代码格式化
map('n', '<leader>fm', '<cmd>Format<cr>', { desc = 'Format current buffer' })

-- 翻译插件
map('n', '<leader>tr', 'viw<cmd>Translate ZH -output=replace<cr>', { desc = 'Translator text and replace(normal)' })
map('v', '<leader>tr', "<cmd>'<,'>Translate ZH -output=replace<cr>", { desc = 'Translator text and repalce(visual)' })
map('n', '<leader>ts', 'viw<cmd>Translate ZH<cr>', { desc = 'Translator text in floating(normal)' })
map('v', '<leader>ts', "<cmd>'<,'>:Translate ZH<cr>", { desc = 'Translator text in floating(visual)' })

-- 项目管理
map('n', '<leader>sl', '<cmd>NeovimProjectLoadRecent<cr>', { desc = 'Load last project session' })
map('n', '<leader>sp', '<cmd>NeovimProjectDiscover<cr>', { desc = 'Select project session for discover' })
map('n', '<leader>sh', '<cmd>NeovimProjectHistory<cr>', { desc = 'Select project session for history' })

-- swtich
map('n', '`', '<cmd>Switch<cr>', { desc = 'Switch segments of text with predefined replacements' })
