-- ##################### 保存本地变量 ##############################
local map = vim.api.nvim_set_keymap
local opt = {noremap = true, silent = true }

-- ################# 设置代码 V 模式连续移动 #######################

-- 窗口设置
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

-- 侧边栏和 tab 切换
-- 打开侧边栏
map('n', '<A-1>', ':NvimTreeToggle<CR>', opt)
-- tab 键切换
map("n", "<C-~>", ":BufferLineCycleNext<CR>", opt)

-- 反缩进连续
map('v', '<', '<gv', opt)
-- 缩进连续
map('v', '>', '>gv', opt)

-- ######################### 其他配置 #############################
-- 粘贴后不复制被粘贴的文本
map("v", "p", '"_dp', opt)
-- 设置 jk 映射 <esc>
map('i', 'jk', '<esc>', opt)


-- ####################### leader 设置 ############################
-- 设置 leader 键
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ####################### 文件操作配置 ###########################
map("n", "<leader>fm", "gg=G", opt)

-- ######################### 窗体配置 #############################
map("n", "<leader>c", ":BufferLinePickClose<CR>", opt)
