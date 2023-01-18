local G = require('G')

-- 设置 python3 对应的目录，你可以手动 export PYTHON=$(which python3) 到你的终端配置中
G.cmd([[
    let g:python3_host_prog = $PYTHON
]])

-- 设置命令提示 唯一标识 共享剪贴板
-- [[
-- set showcmd 命令提示
-- set encoding 编码格式
-- set wildmenu 命令 tab 提示
-- set pumheight 弹出窗口的最大高度
-- set conceallevel 是否显示可隐藏文本
-- set clipboard 共享系统剪切版
-- ]]
G.cmd([[
    set showcmd
    set encoding=utf-8
    set wildmenu
    set pumheight=10
    set conceallevel=0
    set clipboard=unnamed
    set clipboard+=unnamedplus
]])

-- 搜索高亮 空格+回车 去除匹配高亮 延迟
-- [[
-- set hlsearch 设置高亮
-- set showmatch 插入括号时短暂跳转到配备括号
-- nh 取消高亮
-- set incsearch 输入搜索模式时同时高亮部分的匹配
-- set inccommand 命令效果预览
-- set ignorecase 搜索时忽略大小写
-- set smartcase 模式中有大小写时不忽略大小写
-- set timeoutlen 超时时间(毫秒)
-- ]]
G.cmd([[
    set hlsearch
    set showmatch
    noremap \ :nohlsearch<CR>
    set incsearch
    set inccommand=
    set ignorecase
    set smartcase
    set timeoutlen=1500
]])

-- 设置正常删除 光标穿越行
-- [[
-- set backspace 退格键处理
-- set whichwrap 允许指定键跨域行边界
-- ]]
G.cmd([[
    set backspace=indent,eol,start
    set whichwrap+=<,>,h,
]])

-- 设置允许鼠标移动
G.cmd([[
    set mouse=a
]])

-- 错误无提示音 去除屏幕闪烁
G.cmd([[
    set vb
    set t_vb=""
    set t_ut=""
    set hidden
]])

-- 缩进对齐
-- [[
-- set autoindent 根据上一行来决定下一行缩进
-- set smartindent C 程序自动智能缩进
-- set tabstop 在文件中使用的空格数
-- set softtabstop 编辑时使用的空格数
-- set shiftwidth (自动)缩进使用的步进单位,以空白数目计
-- set smarttab 插入时 shiftwidth
-- set expandtab 键入时使用空格
-- ]]
G.cmd([[
    set autoindent
    set smartindent
    set tabstop=2
    set softtabstop=2
    set shiftwidth=2
    set smarttab
    set expandtab
]])

-- 不自动备份 不换行
G.cmd([[
    set nobackup
    set noswapfile
    set nowrap
]])

-- 光标回到上次位置
G.cmd([[ au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif ]])

-- 持久化撤销
G.cmd([[
    set undofile
    set undodir=~/.config/nvim/cache/undodir
]])
-- vim保存1000条文件记录
G.cmd([[ set viminfo=!,'10000,<50,s10,h ]])

-- 折叠
G.cmd([[
    set foldenable
    set foldmethod=manual
    set viewdir=~/.config/nvim/cache/viewdir
]])

-- show
-- [[
-- colorscheme 设置主题,路径 $NVIM/colors/..
-- set cmdheight 命令行使用的行数
-- set updatetime 刷新交换文件所需的毫秒数
-- set shortmess 缩短消息长度的标志位列表
-- set scrolloff 光标上下的最少行数
-- set sidescrolloff 在光标左右最少出现列数
-- set noshowmode 不再在状态行上显示当前模式的消息
-- set nu 设置行号
-- set numberwidth 行号使用的列数
-- set relativenumber 使用相对行号
-- set cul 高亮光标所在行
-- set signcolumn 显示左侧图标指示行
-- set fillchars 显示特殊项目所使用的字符
-- set &t 光标样式设置
-- ]]
G.cmd([[
    colorscheme solarized8_high
    set cmdheight=1
    set updatetime=300
    set shortmess+=cI
    set scrolloff=30
    set sidescrolloff=30
    set noshowmode
    set nu
    set numberwidth=2
    set relativenumber
    set cul
    set signcolumn=yes
    let &t_SI.="\e[5 q"
    let &t_EI.="\e[1 q"
    set fillchars=stlnc:#
]])
