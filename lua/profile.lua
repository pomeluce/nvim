local G = require('G')

-- 设置 python3 对应的目录，你可以手动 export PYTHON=$(which python3) 到你的终端配置中
G.g.python3_host_prog = os.getenv("PYTHON")

-- 命令提示
G.g.showcmd = true
G.g.encoding = "utf-8"
-- tab 键提示
G.o.wildmenu = true
-- 插入模式补全提示的数目
G.o.pumheight = 10
-- 是否显示可隐藏文本
G.wo.conceallevel = 0
-- 共享系统剪切版
G.opt.clipboard = 'unnamedplus'
-- 搜索高亮
G.o.hlsearch = true
-- 插入括号时短暂跳转到配备括号
G.o.showmatch = true
-- 输入搜索模式时同时高亮部分的匹配
G.o.incsearch = true
-- 命令效果预览
G.o.inccommand = "split"
-- 搜索模式忽略大小写
G.o.ignorecase = true
-- 模式中有大小写时不忽略大小写
G.o.smartcase = true
-- 超时时间
G.o.timeoutlen = 1500
-- 退格键处理
G.opt.backspace = "indent,eol,start"
-- 允许换行跨越边界
G.o.whichwrap = "<,>,[,],h,l"
-- 允许鼠标移动
G.o.mouse = "a"
-- 错误无提示音 去除屏幕闪烁
G.o.vb = true
G.o.t_vb = ""
G.o.t_ut = ""
-- 允许隐藏被修改过的 buffer
G.o.hidden = true
-- 新行和上一行对齐
G.o.autoindent = true
-- 开启新行时, 使用智能缩进
G.o.smartindent = true
-- 缩进 tab 为 2 个空格
G.bo.tabstop = 2
-- 编辑时使用的空格数
G.o.softtabstop = 2
-- 自动缩进为 2 个空格
G.o.shiftwidth = 2
-- 插入时行首根据 shiftwidth 插入空白
G.o.smarttab = true
-- 使用空格代替 tab
G.o.expandtab = true
-- 不自动备份, 不设置交换文件, 不换行
G.o.backup = false
G.o.swapfile = false
G.wo.wrap = false
-- 持久化撤销
G.o.undofile = true
G.o.undodir = os.getenv("HOME") .. "/.config/nvim/cache/undodir"
-- vim 保存 1000 条文件记录
G.o.viminfo = "!,'10000,<50,s10,h"
-- 开启折叠
G.o.foldenable = true
-- 手动建立折叠
G.o.foldmethod = "manual"
G.o.viewdir = os.getenv("HOME") .. "/.config/nvim/cache/viewdir"
-- 设置命令行高度
G.o.cmdheight = 1
-- 刷新交换文件所需的毫秒数
G.o.updatetime = 300
-- 缩短消息长度的标志位列表
G.o.shortmess = G.o.shortmess .. 'cI'
-- 光标上下左右保留 30 行
G.o.scrolloff = 30
G.o.sidescrolloff = 30
-- 显示行号
G.wo.number = true
-- 显示相对行号
G.wo.relativenumber = true
-- 行号使用 2 列
G.wo.numberwidth = 2
-- 高亮当前行
G.wo.cul = true
-- 显示左侧图标指示列
G.wo.signcolumn = "yes"
G.o.fillchars = "stlnc:-"
G.cmd([[
    let &t_SI.="\e[5 q"
    let &t_EI.="\e[1 q"
]])
