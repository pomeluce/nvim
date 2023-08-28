local M = {}

local keymap = vim.keymap.set

-- 声明 leader 键
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- TODO: 基础配置
-- 基本键位映射
keymap('n', 's', '<nop>', {})
keymap({ 'n', 'v' }, ';', ':', { desc = 'into cmd mode' })
keymap('i', 'jk', '<esc>', { desc = 'Esc', noremap = true, silent = true })
keymap('n', 'S', ':MagicSave<cr>', { desc = 'save file', noremap = true, silent = true })
keymap('n', 'Q', ':q!<cr>', { desc = 'confrim exit', noremap = true, silent = true })
keymap('n', 'j', '<Plug>(accelerated_jk_gj)', { noremap = true })
keymap('n', 'k', '<Plug>(accelerated_jk_gk)', { noremap = true })
-- 设置删除后不复制删除后的文本
keymap('v', 'c', '"_c', { noremap = true })
-- 粘贴之后不复制被粘贴的文本
keymap('v', 'p', '"_dhp', { noremap = true, silent = true })
-- 选中全文, 从当前选中的 { 复制全文
keymap('n', '<m-a>', 'ggVG', { desc = 'select all text', noremap = true })
keymap('n', '<m-s>', 'vi{', { desc = 'select brackets text', noremap = true })
-- 全局替换 c-s = :%s/
keymap('n', '<c-s>', ':%s/\\v//gc<left><left><left><left>', { desc = 'global repalce', noremap = true })
keymap('v', '<c-s>', ':s/\\v//gc<left><left><left><left>', { desc = 'global repalce', noremap = true })
-- 取消搜索高亮
keymap('n', '<leader>nh', ':nohlsearch<cr>', { desc = 'unhighlight', noremap = true, silent = true })
-- space 行首行尾跳转
keymap('n', '<space>', ':MagicMove<cr>', { desc = 'jump line start to end', noremap = true, silent = true })
keymap('n', '0', '%', { noremap = true })
keymap('v', '0', '%', { noremap = true })

-- TODO: 窗口相关设置
-- 设置水平分屏,并切换到下一个窗口
keymap('n', 'sv', ':vsp<cr><c-w>w', { desc = 'split horizontal', noremap = true })
-- 设置垂直分屏,并切换到下一个窗口
keymap('n', 'sp', ':sp<cr><c-w>w', { desc = 'split vertical', noremap = true })
-- 关闭当前窗口
keymap('n', 'sc', ':close<cr>', { desc = 'close current window', noremap = true })
-- 关闭其他窗口
keymap('n', 'so', ':only<cr>', { desc = 'close other window', noremap = true })
-- 设置窗口跳转
keymap('n', '<c-h>', '<c-w>h', { desc = 'jump to left window', noremap = true })
keymap('n', '<c-l>', '<c-w>l', { desc = 'jump to right window', noremap = true })
keymap('n', '<c-k>', '<c-w>k', { desc = 'jump to top window', noremap = true })
keymap('n', '<c-j>', '<c-w>j', { desc = 'jump to bottom window', noremap = true })
keymap('n', '<c-Space>', function()
  local window_number = require('window-picker').pick_window()
  if window_number then
    vim.api.nvim_set_current_win(window_number)
  end
end, { desc = 'order jump all window', noremap = true })
-- 调整窗口尺寸 winnr() <= winner 判断是否为最后一个窗口
keymap('n', 's=', '<c-w>=', { desc = 'resize all window same size', noremap = true })
keymap('n', 's.', "winnr() <= winnr('$') - winnr() ? '<c-w>10>' : '<c-w>10<'", { desc = 'extend window to right', noremap = true, expr = true })
keymap('n', 's,', "winnr() <= winnr('$') - winnr() ? '<c-w>10<' : '<c-w>10>'", { desc = 'extend window to left', noremap = true, expr = true })
keymap('n', 'sj', "winnr() <= winnr('$') - winnr() ? '<c-w>10+' : '<c-w>10-'", { desc = 'extend window to top', noremap = true, expr = true })
keymap('n', 'sk', "winnr() <= winnr('$') - winnr() ? '<c-w>10-' : '<c-w>10+'", { desc = 'extent window to bottom', noremap = true, expr = true })
-- buffer 切换
keymap('n', 'ss', ':bn<cr>', { desc = 'cycle toggle buffer', noremap = true, silent = true })
-- 关闭当前 buffer
keymap('n', '<leader>c', ':bw<cr>', { desc = 'close current buffer', noremap = true, silent = true })
-- 前后切换 buffer
keymap({ 'n', 'v', 'i' }, '<m-left>', '<esc>:bp<cr>', { desc = 'toggle front buffer', noremap = true, silent = true })
keymap({ 'n', 'v', 'i' }, '<m-right>', '<esc>:bn<cr>', { desc = 'toggle later buffer', noremap = true, silent = true })

-- TODO: 代码跳转配置
-- flash 跳转配置
keymap({ 'n', 'x', 'o' }, 's', function()
  require('flash').jump { search = {
    mode = function(str)
      return '\\<' .. str
    end,
  } }
end, { desc = 'flash code jump' })
-- flash 选中配置
keymap({ 'n', 'x', 'o' }, 'fs', function()
  require('flash').treesitter()
end, { desc = 'flash code select' })
-- flash 跳转复制
keymap({ 'o' }, 'r', function()
  require('flash').remote()
end, { desc = 'flash code jump and copy' })
-- flash 选择复制
keymap({ 'o', 'x' }, 'fr', function()
  require('flash').treesitter_search()
end, { desc = 'flash code select and copy' })
-- 跳转到上次编辑位置
keymap('n', 'ga', "'.", { desc = 'jump to last edit', noremap = true, silent = true })
-- 行尾添加分号
keymap('n', 'g;', '$a;<esc>', { desc = 'add semicolon for endline', noremap = true, silent = true })

-- TODO: 代码光标移动
-- 插入模式下移动
keymap('i', '<m-h>', '<left>', { desc = 'insert mode left move', noremap = true })
keymap('i', '<m-l>', '<right>', { desc = 'insert mode right move', noremap = true })
keymap('i', '<m-k>', '<up>', { desc = 'insert mode top move', noremap = true })
keymap('i', '<m-j>', '<down>', { desc = 'insert mode bottom move', noremap = true })
-- 向上移动行
keymap('n', '<c-m-J>', ':m+<cr>', { desc = 'move row up', noremap = true, silent = true })
keymap('i', '<c-m-J>', '<esc>:m+<cr>i', { desc = 'move row up', noremap = true, silent = true })
keymap('v', '<c-m-J>', ":move '>+1<cr>gv", { desc = 'move row up', noremap = true, silent = true })
keymap('v', 'J', ":move '>+1<cr>gv", { desc = 'move row up', noremap = true, silent = true })
-- 向下移动行
keymap('n', '<c-m-K>', ':m-2<cr>', { desc = 'move row down', noremap = true, silent = true })
keymap('i', '<c-m-K>', '<esc>:m-2<cr>i', { desc = 'move row down', noremap = true, silent = true })
keymap('v', '<c-m-K>', ":move '<-2<cr>gv", { desc = 'move row down', noremap = true, silent = true })
keymap('v', 'K', ":move '<-2<cr>gv", { desc = 'move row down', noremap = true, silent = true })

-- TODO: 代码连续缩进
keymap('v', '<', '<gv', { desc = 'indent left', noremap = true })
keymap('v', '>', '>gv', { desc = 'indent right', noremap = true })
keymap('v', '<s-tab>', '<gv', { desc = 'indent left', noremap = true })
keymap('v', '<tab>', '>gv', { desc = 'indent right', noremap = true })

-- TODO: 代码折叠
keymap('n', 'zz', "foldlevel('.') > 0 ? 'za' : 'va{zf^'", { desc = 'toggle fold', noremap = true, silent = true, expr = true })
keymap('v', 'z', 'zf', { desc = 'add fold', noremap = true, silent = true })

-- TODO: git 操作
-- 当前行 git 提交历史查看
keymap('n', 'C', ':lua require("gitsigns").blame_line { full = true }<cr>', { desc = 'check blame line', silent = true, noremap = true })
-- 切换显示当前行 git 提交历史
keymap('n', '\\g', ':lua require("gitsigns").toggle_current_line_blame()<cr>', { desc = 'toggle show blame line', silent = true })
-- 文本翻译
-- keymap('n', '<leader>t', "<Plug>(coc-translator-p)", { silent = true })
-- keymap('v', '<leader>t', "<Plug>(coc-translator-pv)", { silent = true })

-- TODO: 其他配置
-- 驼峰转换
keymap('v', 't', ':lua require("user.core.funcutil").toggleHump(false)<cr>', { desc = 'toggle hump', noremap = true, silent = true })
keymap('v', 'T', ':lua require("user.core.funcutil").toggleHump(true)<cr>', { desc = 'toggle hump', noremap = true, silent = true })

-- TODO: 浮动终端
keymap('n', '<F5>', ':lua require("user.plugins.vim-floaterm").runFile()<cr>', { desc = 'run file', noremap = true, silent = true })
keymap('i', '<F5>', '<esc>:lua require("user.plugins.vim-floaterm").runFile()<cr>', { desc = 'run file', noremap = true, silent = true })

-- TODO: telescope 配置
-- 全局文本搜索(yay -S the_silver_searcher fd bat)
keymap('n', '<leader>ft', ':Telescope live_grep<cr>', { desc = 'global search text', noremap = true, silent = true })
-- 文件列表查找
keymap('n', '<leader>ff', ':Telescope find_files<cr>', { desc = 'search file', noremap = true, silent = true })
-- 在已开的 buffer 中查找
keymap('n', '<leader>fb', ':Telescope buffers theme=dropdown<cr>', { desc = 'search opened buffer', noremap = true, silent = true })
-- 当前文本内容查找
keymap('n', '<leader>fw', ':Telescope current_buffer_fuzzy_find<cr>', { desc = 'current buffer search text', noremap = true, silent = true })
-- git 文件查找
keymap('n', '<leader>fg', ':Telescope git_status<cr>', { desc = 'search git status file', noremap = true, silent = true })
-- 查看历史文件
keymap('n', '<leader>fh', ':Telescope oldfiles<cr>', { desc = 'search history file', noremap = true, silent = true })
-- 查看项目列表
keymap('n', '<leader>fp', ':Telescope projects theme=dropdown<cr>', { desc = 'show history projects', noremap = true, silent = true })

-- TODO: tree-sitter 语法高亮
-- 查看语法高亮
keymap('n', 'H', ':Inspect<CR>', { desc = 'show sitter info', noremap = true, silent = true })
-- 刷新语法高亮
keymap('n', 'R', ':write | edit | TSBufEnable highlight<CR>', { desc = 'reference treesitter', silent = true, noremap = true })

-- TODO: nvim-tree
-- 打开文件树
keymap(
  'n',
  'T',
  'g:nvim_tree_firsttime != 1 ? ":NvimTreeToggle<cr>" : ":let g:nvim_tree_firsttime = 0<cr>:NvimTreeToggle $PWD<cr>"',
  { desc = 'toggle tree', noremap = true, silent = true, expr = true }
)

-- TODO: dashboard 封面快捷键
keymap('n', '<leader>sp', ':cd  /wsp/code/web | NvimTreeOpen<cr>', { desc = 'show workspace list', noremap = true, silent = true })
keymap('n', '<leader>es', ':edit $MYVIMRC<cr>', { desc = 'edit vim config', noremap = true, silent = true })
keymap('n', '<leader>ek', ':edit $HOME/.config/nvim/lua/user/core/keymap.lua<cr>', { desc = 'edito vim keymap', noremap = true, silent = true })

-- TODO: session 管理
-- 恢复当前目录 session
keymap('n', '<leader>qs', [[<cmd>lua require("persistence").load()<cr>]], { desc = 'load current session' })
-- 恢复上次 session
keymap('n', '<leader>ql', [[<cmd>lua require("persistence").load({ last = true })<cr>]], { desc = 'load last session' })
-- 停止 persistence, 退出时不保存 session
keymap('n', '<leader>qd', [[<cmd>lua require("persistence").stop()<cr>]], { desc = 'stop persistence' })

-- TODO: Dap 快捷键配置
keymap('n', '<F2>', function()
  require('telescope').extensions.dap.configurations {}
end, { desc = 'start breakpoint debug' })
keymap('n', '<F10>', function()
  require('dap').step_over()
end, { desc = 'step over breakpoint debug' })
keymap('n', '<F11>', function()
  require('dap').step_into()
end, { desc = 'step into breakpoint debug' })
keymap('n', '<F12>', function()
  require('dap').step_out()
end, { desc = 'step out breakpoint debug' })
keymap('n', '<Leader>b', function()
  require('dap').toggle_breakpoint()
end, { desc = 'toggle breakpoint debug' })
keymap('n', '<Leader>B', function()
  require('dap').set_breakpoint()
end, { desc = 'set breakpoint debug' })
keymap('n', '<Leader>lp', function()
  require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
end, { desc = 'log point breakpoint debug' })
keymap('n', '<Leader>dr', function()
  require('dap').repl.open()
end, { desc = 'open debug repl' })
keymap('n', '<Leader>dl', function()
  require('dap').run_last()
end, { desc = 'run last debug' })
keymap({ 'n', 'v' }, '<Leader>dh', function()
  require('dap.ui.widgets').hover()
end, { desc = 'debug hover' })
keymap({ 'n', 'v' }, '<Leader>dp', function()
  require('dap.ui.widgets').preview()
end, { desc = 'debug preview' })
keymap('n', '<Leader>df', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.frames)
end, { desc = 'float show debug frames' })
keymap('n', '<Leader>ds', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.scopes)
end, { desc = 'float show debug scopes' })

-- TODO: lsp 快捷键设置
M.lsp_keymaps = function(buffer)
  -- 重命名
  keymap('n', '<leader>rn', '<cmd>Lspsaga rename ++project<cr>', { desc = 'rename variable', buffer = buffer, noremap = true, silent = true })
  -- 跳转到定义
  keymap('n', 'gd', require('telescope.builtin').lsp_definitions, { desc = 'goto definitions', buffer = buffer, noremap = true, silent = true })
  -- 跳转到声明
  keymap('n', 'gD', require('telescope.builtin').lsp_type_definitions, { desc = 'goto declaration', buffer = buffer, noremap = true, silent = true })
  -- 跳转到类型定义
  keymap('n', 'gt', require('telescope.builtin').lsp_type_definitions, { desc = 'goto type definitions', buffer = buffer, noremap = true, silent = true })
  -- 跳转到实现
  keymap('n', 'gi', require('telescope.builtin').lsp_implementations, { desc = 'goto implementation', buffer = buffer, noremap = true, silent = true })
  -- 跳转到引用
  keymap('n', 'gr', require('telescope.builtin').lsp_references, { desc = 'goto reference', buffer = buffer, noremap = true, silent = true })
  -- 跳转到错误
  keymap('n', 'ge', ':lua require("telescope.builtin").diagnostics({ bufnr = 0 })<cr>', { desc = 'goto error', buffer = buffer, noremap = true, silent = true })
  -- 显示 structure 列表
  keymap('n', '<leader>ss', '<cmd>Lspsaga outline<cr>', { desc = 'structure list', buffer = buffer, noremap = true, silent = true })
  -- 显示文档
  keymap('n', 'K', '<cmd>Lspsaga hover_doc<cr>', { desc = 'hover documents', buffer = buffer, noremap = true, silent = true })
  -- code action 代码修复
  keymap({ 'n', 'v' }, '<m-cr>', '<cmd>Lspsaga code_action<cr>', { desc = 'code action', buffer = buffer, noremap = true, silent = true })
  -- 格式化命令
  -- keymap('n', '<leader>fm', function() vim.lsp.buf.format { async = true } end, { desc = 'format for code', buffer = buffer, noremap = true, silent = true })
  keymap('n', '<leader>fm', '<cmd>Format<cr>', { desc = 'format for code', buffer = buffer, noremap = true, silent = true })
end

return M
