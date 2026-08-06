-- 声明 leader 键
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- 禁用语言的默认提供者
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- 大文件限制
vim.g.bigfile_size = 1024 * 1024 * 1.5 -- 1.5 MB

-- 全局变量用于保存 root_dir -> dialect 的映射
vim.g.sql_dialect_override = {}
