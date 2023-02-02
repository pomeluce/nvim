local opt = vim.opt

-- 设置 python3 对应的目录，你可以手动 export PYTHON=$(which python3) 到你的终端配置中
vim.g.python3_host_prog = os.getenv("PYTHON")

-- 命令提示
opt.showcmd = true
opt.encoding = "utf-8"

-- tab 键提示
opt.wildmenu = true

-- 插入模式补全提示的数目
opt.pumheight = 10

-- 是否显示可隐藏文本
opt.conceallevel = 0

-- 共享系统剪切版
opt.clipboard:append('unnamedplus')

-- 搜索高亮
opt.hlsearch = true

-- 插入括号时短暂跳转到配备括号
opt.showmatch = true

-- 输入搜索模式时同时高亮部分的匹配
opt.incsearch = true

-- 命令效果预览
opt.inccommand = "split"

-- 搜索模式忽略大小写
opt.ignorecase = true

-- 模式中有大小写时不忽略大小写
opt.smartcase = true

-- 超时时间
opt.timeoutlen = 1500

-- 退格键处理
opt.backspace = "indent,eol,start"

-- 允许换行跨越边界
opt.whichwrap = "<,>,[,],h,l"

-- 允许鼠标移动
opt.mouse = "a"

-- 错误无提示音 去除屏幕闪烁
opt.vb = true

-- 允许隐藏被修改过的 buffer
opt.hidden = true

-- 新行和上一行对齐
opt.autoindent = true

-- 开启新行时, 使用智能缩进
opt.smartindent = true

-- 缩进 tab 为 2 个空格
opt.tabstop = 2

-- 编辑时使用的空格数
opt.softtabstop = 2

-- 自动缩进为 2 个空格
opt.shiftwidth = 2

-- 插入时行首根据 shiftwidth 插入空白
opt.smarttab = true

-- 使用空格代替 tab
opt.expandtab = true

-- 不自动备份, 不设置交换文件, 不换行
opt.backup = false
opt.swapfile = false
opt.wrap = false

-- 持久化撤销
opt.undofile = true
opt.undodir = os.getenv("HOME") .. "/.config/nvim/cache/undodir"

-- vim 保存 1000 条文件记录
opt.viminfo = "!,'10000,<50,s10,h"

-- 开启折叠
opt.foldenable = true

-- 手动建立折叠
opt.foldmethod = "manual"
opt.viewdir = os.getenv("HOME") .. "/.config/nvim/cache/viewdir"

-- 设置命令行高度
opt.cmdheight = 1

-- 刷新交换文件所需的毫秒数
opt.updatetime = 300

-- 缩短消息长度的标志位列表
opt.shortmess:append('cI')

-- 光标上下左右保留 30 行
opt.scrolloff = 30
opt.sidescrolloff = 30

-- 显示行号
opt.number = true

-- 显示相对行号
opt.relativenumber = true

-- 行号使用 2 列
opt.numberwidth = 2

-- 高亮当前行
opt.cul = true

-- 显示左侧图标指示列
opt.signcolumn = "yes"
opt.fillchars = "stlnc:-"
vim.cmd([[
    let &t_SI.="\e[5 q"
    let &t_EI.="\e[1 q"
]])
