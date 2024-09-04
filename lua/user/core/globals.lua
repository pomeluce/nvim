-- 声明 leader 键
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- 设置 python3 对应的目录，你可以手动 export PYTHON=$(which python3) 到你的终端配置中
vim.g.python3_host_prog = os.getenv('PYTHON')

-- 禁用语言的默认提供者
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
