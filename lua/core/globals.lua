-- 替换 vim.pack.add 函数
require('configs.pack').pack_state()

-- 声明 leader 键
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- 设置 python3 对应的目录, 你可以手动 export PYTHON=$(which python3) 到你的终端配置中
vim.g.python3_host_prog = os.getenv('PYTHON')

-- 大文件限制
vim.g.bigfile_size = 1024 * 1024 * 1.5 -- 1.5 MB

-- 全局变量用于保存 root_dir -> dialect 的映射
vim.g.sql_dialect_override = {}
