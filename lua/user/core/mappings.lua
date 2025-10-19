local M = {}

local map = function(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_extend('force', { silent = true }, opts or {}))
end

M.map = map

--[[ 基础配置 ]]
-- 基本键位映射
map('n', 's', '<nop>', {})
map({ 'n', 'v' }, ';', ':', { desc = 'into cmd mode', silent = false })
map('n', 'S', ':AkirSave<cr>', { desc = 'save file' })
map('n', 'Q', ':q!<cr>', { desc = 'confrim exit' })
map('t', '<leader><esc>', '<c-\\><c-n>', { desc = 'change terminal to normal mode' })

-- 设置删除后不复制删除后的文本
map('v', 'c', '"_c', {})

-- 粘贴之后不复制被粘贴的文本
map('v', 'p', '"_dhp', {})

-- 选中全文, 从当前选中的 { 复制全文
map('n', '<m-a>', 'ggVG', { desc = 'select all text' })
map('n', '<m-s>', 'vi{', { desc = 'select brackets text' })

-- 全局替换 c-s = :%s/
map('n', '<c-s>', ':%s/\\v//gc<left><left><left><left>', { desc = 'global repalce', silent = false })
map('v', '<c-s>', ':s/\\v//gc<left><left><left><left>', { desc = 'global repalce', silent = false })

-- 取消搜索高亮
map('n', '<leader>nh', ':nohlsearch<cr>', { desc = 'unhighlight' })

-- space 行首行尾跳转
map('n', '<space>', ':AkirJump<cr>', { desc = 'jump line start to end' })
map('n', '0', '%', {})
map('v', '0', '%', {})

-- 切换主题
map('n', '<leader>tt', ':lua require("nvchad.themes").open()<cr>', { desc = 'toggle theme' })

--[[ 窗口相关设置 ]]

-- 设置水平分屏,并切换到下一个窗口
map('n', 'sv', ':vsp<cr><c-w>w', { desc = 'split horizontal' })

-- 设置垂直分屏,并切换到下一个窗口
map('n', 'sp', ':sp<cr><c-w>w', { desc = 'split vertical' })

-- 关闭当前窗口
map('n', 'sc', ':close<cr>', { desc = 'close current window' })

-- 关闭其他窗口
map('n', 'so', ':only<cr>', { desc = 'close other window' })

-- 设置窗口跳转
map('n', '<c-h>', '<c-w>h', { desc = 'jump to left window' })
map('n', '<c-l>', '<c-w>l', { desc = 'jump to right window' })
map('n', '<c-k>', '<c-w>k', { desc = 'jump to top window' })
map('n', '<c-j>', '<c-w>j', { desc = 'jump to bottom window' })
map('n', '<c-Space>', function()
  local window_number = require('window-picker').pick_window()
  if window_number then
    vim.api.nvim_set_current_win(window_number)
  end
end, { desc = 'order jump all window' })

-- 调整窗口尺寸 winnr() <= winner 判断是否为最后一个窗口
map('n', 's=', '<c-w>=', { desc = 'resize all window same size' })
map('n', 's.', "winnr() <= winnr('$') - winnr() ? '<c-w>10>' : '<c-w>10<'", { desc = 'extend window to right', expr = true })
map('n', 's,', "winnr() <= winnr('$') - winnr() ? '<c-w>10<' : '<c-w>10>'", { desc = 'extend window to left', expr = true })
map('n', 'sj', "winnr() <= winnr('$') - winnr() ? '<c-w>10+' : '<c-w>10-'", { desc = 'extend window to top', expr = true })
map('n', 'sk', "winnr() <= winnr('$') - winnr() ? '<c-w>10-' : '<c-w>10+'", { desc = 'extent window to bottom', expr = true })

-- buffer 切换
map('n', 'ss', ':bn<cr>', { desc = 'cycle toggle buffer' })

-- 关闭当前 buffer
map('n', '<leader>c', ':lua require("nvchad.tabufline").close_buffer()<cr>', { desc = 'close current buffer' })

-- 前后切换 buffer
map('n', '<tab>', ':lua require("nvchad.tabufline").next()<cr>', { desc = 'buffer goto next' })
map('n', '<S-tab>', ':lua require("nvchad.tabufline").prev()<cr>', { desc = 'buffer goto prev' })
map({ 'n', 'v', 'i' }, '<m-left>', '<esc>:bp<cr>', { desc = 'buffer goto next' })
map({ 'n', 'v', 'i' }, '<m-right>', '<esc>:bn<cr>', { desc = 'buffer goto prev' })

--[[ 代码跳转配置 ]]

-- flash 跳转配置
map({ 'n', 'x', 'o' }, 's', function()
  require('flash').jump { search = {
    mode = function(str)
      return '\\<' .. str
    end,
  } }
end, { desc = 'flash code jump' })

-- flash 选中配置
map({ 'n', 'x', 'o' }, 'fs', function()
  require('flash').treesitter()
end, { desc = 'flash code select' })

-- flash 跳转复制
map({ 'o' }, 'r', function()
  require('flash').remote()
end, { desc = 'flash code jump and copy' })

-- flash 选择复制
map({ 'o', 'x' }, 'fr', function()
  require('flash').treesitter_search()
end, { desc = 'flash code select and copy' })

-- 跳转到上次编辑位置
map('n', 'ga', "'.", { desc = 'jump to last edit' })

-- 行尾添加分号
map('n', 'g;', '$a;<esc>', { desc = 'add semicolon for endline' })

--[[ 代码光标移动 ]]

-- 插入模式下移动
map('i', '<m-h>', '<left>', { desc = 'insert mode left move' })
map('i', '<m-l>', '<right>', { desc = 'insert mode right move' })
map('i', '<m-k>', '<up>', { desc = 'insert mode top move' })
map('i', '<m-j>', '<down>', { desc = 'insert mode bottom move' })

-- 向上移动行
map('n', '<c-m-J>', ':m+<cr>', { desc = 'move row up' })
map('i', '<c-m-J>', '<esc>:m+<cr>i', { desc = 'move row up' })
map('v', '<c-m-J>', ":move '>+1<cr>gv", { desc = 'move row up' })
map('v', 'J', ":move '>+1<cr>gv", { desc = 'move row up' })

-- 向下移动行
map('n', '<c-m-K>', ':m-2<cr>', { desc = 'move row down' })
map('i', '<c-m-K>', '<esc>:m-2<cr>i', { desc = 'move row down' })
map('v', '<c-m-K>', ":move '<-2<cr>gv", { desc = 'move row down' })
map('v', 'K', ":move '<-2<cr>gv", { desc = 'move row down' })

--[[ 代码连续缩进 ]]
map('v', '<', '<gv', { desc = 'indent left' })
map('v', '>', '>gv', { desc = 'indent right' })
map('v', '<s-tab>', '<gv', { desc = 'indent left' })
map('v', '<tab>', '>gv', { desc = 'indent right' })

--[[ 代码折叠 ]]
map('n', 'zz', "foldlevel('.') > 0 ? 'za' : 'va{zf^'", { desc = 'toggle fold', expr = true })
map('v', 'z', 'zf', { desc = 'add fold' })

--[[ git 操作 ]]

-- 当前行 git 提交历史查看
map('n', 'C', ':lua require("gitsigns").blame_line { full = true }<cr>', { desc = 'check blame line' })

-- 切换显示当前行 git 提交历史
map('n', '\\g', ':lua require("gitsigns").toggle_current_line_blame()<cr>', { desc = 'toggle show blame line' })

--[[ 文本翻译 ]]
map({ 'n', 'v' }, '<leader>tr', ':Translate ZH<CR>', { desc = 'translator text' })

--[[ 驼峰转换 ]]
map('n', 'th', '<cmd>Telescope textcase normal_mode theme=dropdown<CR>', { desc = 'toggle hump' })
map('v', 'th', '<cmd>Telescope textcase visual_mode theme=dropdown<CR>', { desc = 'toggle hump' })

--[[ 浮动终端 ]]
map('n', '<F5>', ':lua require("user.configs.toggleterm").runFile()<cr>', { desc = 'run file' })
map('i', '<F5>', '<esc>:lua require("user.configs.toggleterm").runFile()<cr>', { desc = 'run file' })

--[[ telescope 配置 ]]

-- 全局文本搜索(yay -S the_silver_searcher fd bat)
map('n', '<leader>ft', ':Telescope live_grep<cr>', { desc = 'global search text' })

-- 文件列表查找
map('n', '<leader>ff', ':Telescope find_files<cr>', { desc = 'search file' })

-- 在已开的 buffer 中查找
map('n', '<leader>fb', ':Telescope buffers theme=dropdown<cr>', { desc = 'search opened buffer' })

-- 当前文本内容查找
map('n', '<leader>fw', ':Telescope current_buffer_fuzzy_find<cr>', { desc = 'current buffer search text' })

-- git 文件查找
map('n', '<leader>fg', ':Telescope git_status<cr>', { desc = 'search git status file' })

-- 查看历史文件
map('n', '<leader>fh', ':Telescope oldfiles<cr>', { desc = 'search history file' })

-- 显示 structure 列表
map('n', '<leader>ss', '<cmd>Telescope aerial<cr>', { desc = 'structure list' })

--[[ 格式化命令 ]]
map('n', '<leader>fm', ':lua require("conform").format({ async = true })<cr>', { desc = 'format for code' })

--[[ tree-sitter 语法高亮 ]]

-- 查看语法高亮
map('n', 'H', ':Inspect<CR>', { desc = 'show sitter info' })

-- 刷新语法高亮
map('n', 'R', ':write | edit | TSBufEnable highlight<CR>', { desc = 'reference treesitter' })

--[[ nvim-tree ]]

-- 打开文件树
map('n', 'T', 'g:nvim_tree_firsttime != 1 ? ":NvimTreeToggle<cr>" : ":let g:nvim_tree_firsttime = 0<cr>:NvimTreeToggle $PWD<cr>"', { desc = 'toggle tree', expr = true })

--[[ dashboard 封面快捷键 ]]
map('n', '<leader>es', ':edit $MYVIMRC<cr>', { desc = 'edit vim config' })
map('n', '<leader>ek', ':edit $HOME/.config/nvim/lua/user/core/mappings.lua<cr>', { desc = 'edito vim keymap' })

--[[ 文档注释 ]]
map('n', '<leader>d/', ':lua require("neogen").generate()<cr>', { desc = 'doc comment' })

--[[ -- session 恢复 ]]
map('n', '<leader>sl', ':NeovimProjectLoadRecent<cr>', { desc = 'load last project session' })
map('n', '<leader>sp', ':Telescope neovim-project discover theme=dropdown<cr>', { desc = 'select project session' })
map('n', '<leader>sh', ':Telescope neovim-project history theme=dropdown<cr>', { desc = 'select project session for history' })

--[[ todo 待办标签 ]]
map('n', '<leader>td', ':TodoTelescope theme=dropdown<cr>', { desc = 'todo list' })

--[[ codecompanion AI 代码助手 ]]
map({ 'n', 'v', 'x' }, '<leader>tc', ':lua require("codecompanion").toggle()<cr>', { desc = 'codecompanion chat' })
map({ 'n', 'v', 'x' }, '<leader>ac', ':CodeCompanionActions<cr>', { desc = 'codecompanion actions' })

--[[ Dap 快捷键配置 ]]
map('n', '<F2>', function()
  require('telescope').extensions.dap.configurations {}
end, { desc = 'start breakpoint debug' })
map('n', '<F10>', function()
  require('dap').step_over()
end, { desc = 'step over breakpoint debug' })
map('n', '<F11>', function()
  require('dap').step_into()
end, { desc = 'step into breakpoint debug' })
map('n', '<F12>', function()
  require('dap').step_out()
end, { desc = 'step out breakpoint debug' })
map('n', '<Leader>db', function()
  require('dap').toggle_breakpoint()
end, { desc = 'toggle breakpoint debug' })
map('n', '<Leader>B', function()
  require('dap').set_breakpoint()
end, { desc = 'set breakpoint debug' })
map('n', '<Leader>dm', function()
  require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
end, { desc = 'log point breakpoint debug' })
map('n', '<Leader>dr', function()
  require('dap').repl.open()
end, { desc = 'open debug repl' })
map('n', '<Leader>dl', function()
  require('dap').run_last()
end, { desc = 'run last debug' })
map({ 'n', 'v' }, '<Leader>dh', function()
  require('dap.ui.widgets').hover()
end, { desc = 'debug hover' })
map({ 'n', 'v' }, '<Leader>dp', function()
  require('dap.ui.widgets').preview()
end, { desc = 'debug preview' })
map('n', '<Leader>df', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.frames)
end, { desc = 'float show debug frames' })
map('n', '<Leader>ds', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.scopes)
end, { desc = 'float show debug scopes' })

--[[ lsp 快捷键设置 ]]
M.lsp = function(bufnr)
  -- 重命名
  map('n', '<leader>rn', '<cmd>Lspsaga rename ++project<cr>', { desc = 'rename variable', buffer = bufnr })
  -- 跳转到定义
  map('n', 'gd', '<cmd>Telescope lsp_definitions theme=dropdown<cr>', { desc = 'goto definitions', buffer = bufnr })
  -- 跳转到声明
  map('n', 'gD', '<cmd>Telescope lsp_type_definitions theme=dropdown<cr>', { desc = 'goto declaration', buffer = bufnr })
  -- 跳转到类型定义
  map('n', 'gt', '<cmd>Telescope lsp_type_definitions theme=dropdown<cr>', { desc = 'goto type definitions', buffer = bufnr })
  -- 跳转到实现
  map('n', 'gi', '<cmd>Telescope lsp_implementations theme=dropdown<cr>', { desc = 'goto implementation', buffer = bufnr })
  -- 跳转到引用
  map('n', 'gr', '<cmd>Telescope lsp_references theme=dropdown<cr>', { desc = 'goto reference', buffer = bufnr })
  -- 跳转到错误
  map('n', 'ge', '<cmd>Lspsaga diagnostic_jump_next<cr>', { desc = 'goto error', buffer = bufnr })
  -- 显示文档
  map('n', 'K', '<cmd>Lspsaga hover_doc<cr>', { desc = 'hover documents', buffer = bufnr })
  -- code action 代码修复
  map({ 'n', 'v' }, '<m-cr>', '<cmd>Lspsaga code_action<cr>', { desc = 'code action', buffer = bufnr })
end

return M
