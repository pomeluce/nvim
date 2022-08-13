-- ----------------------- 保存本地变量 --------------------------------------
local map = vim.api.nvim_set_keymap
-- 禁止递归, 执行命令不回显内容
local opt = {noremap = true, silent = true }

-- ---------------------- 快捷键(非 leader) ----------------------------------

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>> 窗口设置 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- 设置水平分屏
map("n", "sv", ":vsp<CR>", opt)
-- 设置垂直分屏
map("n", "sh", ":sp<CR>", opt)
-- 关闭当前窗口
map("n", "sc", "<C-w>c", opt)
-- 关闭其他窗口
map("n", "so", "<C-w>o", opt)

-- 水平增加宽度
map("n", "s.", ":vertical resize +20<CR>", opt)
-- 水平减少宽度
map("n", "s,", ":vertical resize -20<CR>", opt)
-- 垂直降低高度
map("n", "sj", ":resize +10<CR>",opt)
-- 垂直增加高度
map("n", "sk", ":resize -10<CR>",opt)


-- 设置窗口跳转
map("n", "<C-h>", "<C-w>h", opt)
map("n", "<C-j>", "<C-w>j", opt)
map("n", "<C-k>", "<C-w>k", opt)
map("n", "<C-l>", "<C-w>l", opt)

-- 打开侧边栏
map('n', '<A-1>', ':NvimTreeToggle<CR>', opt)
-- tab 键切换
map("n", "<C-~>", ":BufferLineCycleNext<CR>", opt)

-- >>>>>>>>>>>>>>>>>>>>>>>>>>> V 模式连续缩进 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- 反缩进连续
map('v', '<', '<gv', opt)
-- 缩进连续
map('v', '>', '>gv', opt)

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>> 其他配置 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- 粘贴后不复制被粘贴的文本
map("v", "p", '"_dp', opt)
-- 设置 jk 映射 <esc>
map('i', 'jk', '<esc>', opt)


-- ####################### 快捷键(leader) ############################
-- 设置 leader 键
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- >>>>>>>>>>>>>>>>>>>>>>> 文件操作配置 <<<<<<<<<<<<<<<<<<<<<<<<<<<
-- 代码格式化
map("n", "<leader>fm", "gg=G<C-o>", opt)
-- 文件查找
map("n", "<leader>ff", ":Telescope find_files<CR>", opt)

-- >>>>>>>>>>>>>>>>>>>>>> 显示设置 <<<<<<<<<<<<<<<<<<<<<<<<<<<
-- 取消搜索高亮
map("n", "<leader>nh", ":nohlsearch<CR>", opt)

-- >>>>>>>>>>>>>>>>>>>>>>>> 窗体配置 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- 关闭当前 tab
map("n", "<leader>cc", ":bdelete %<CR>", opt)
-- 关闭其他 tab
map("n", "<leader>co", ":BufferLineCloseLeft<CR>:BufferLineCloseRight<CR>", opt)


-- ############################ 插件配置列表 ##################################
-- 插件快捷键
local pluginKeys = {}

-- 列表快捷键
pluginKeys.nvimTreeList = {
  -- 打开文件或文件夹
  { key = { "o", "<2-LeftMouse>" }, action = "edit" },
  -- { key = "<CR>", action = "edit" },
  -- v分屏打开文件
  { key = "v", action = "vsplit" },
  -- h分屏打开文件
  { key = "h", action = "split" },
  -- Ignore (node_modules)
  { key = "i", action = "toggle_ignored" },
  -- Hide (dotfiles)
  { key = ".", action = "toggle_dotfiles" },
  { key = "R", action = "refresh" },
  -- 文件操作
  { key = "a", action = "create" },
  { key = "d", action = "remove" },
  { key = "r", action = "rename" },
  { key = "x", action = "cut" },
  { key = "c", action = "copy" },
  { key = "p", action = "paste" },
  { key = "y", action = "copy_name" },
  { key = "Y", action = "copy_path" },
  { key = "gy", action = "copy_absolute_path" },
  { key = "I", action = "toggle_file_info" },
  { key = "n", action = "tabnew" },
  -- 进入下一级
  { key = { "]" }, action = "cd" },
  -- 进入上一级
  { key = { "[" }, action = "dir_up" },
}
return pluginKeys
