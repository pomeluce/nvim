local opt = vim.opt

-- 启用真彩色支持
opt.termguicolors = true

-- 状态栏全局显示
opt.laststatus = 3
-- 光标行高亮
opt.cursorline = true
-- 只高亮行号部分
opt.cursorlineopt = 'number'

-- 禁用右下角的标尺显示
opt.ruler = false
-- 新建的水平分割窗口会出现在当前窗口的下方。
opt.splitbelow = true
-- 新建的垂直分割窗口会出现在当前窗口的右侧
opt.splitright = true

-- 设置文件默认格式
opt.fileformat = 'unix'
opt.fileformats = { 'unix', 'dos', 'mac' }

-- 命令提示
opt.showcmd = true
opt.encoding = 'utf-8'

-- tab 键提示
opt.wildmenu = true

-- 插入模式补全提示的数目
opt.pumheight = 10

-- 是否显示可隐藏文本
opt.conceallevel = 0

-- 设置 neovim 在编辑器中如何显示某些空白字符
--  See `:help 'list'`
--  and `:help 'listchars'`
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- 共享系统剪切版
-- 在 `UiEnter` 之后安排此设置, 因为它可能增加启动时间。
-- 如果你希望操作系统剪贴板保持独立, 请移除此选项
--  See `:help 'clipboard'`
vim.schedule(function() opt.clipboard:append('unnamedplus') end)

-- 搜索高亮
opt.hlsearch = false

-- 插入括号时短暂跳转到配备括号
opt.showmatch = true

-- 输入搜索模式时同时高亮部分的匹配
opt.incsearch = true

-- 命令效果预览
opt.inccommand = 'split'

-- 搜索模式忽略大小写
opt.ignorecase = true

-- 模式中有大小写时不忽略大小写
opt.smartcase = true

-- 超时时间
opt.timeoutlen = 500

-- 退格键处理
opt.backspace = 'indent,eol,start'

-- 允许换行跨越边界
opt.whichwrap = '<,>,[,],h,l'

-- 允许鼠标移动
opt.mouse = 'a'

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

-- 不自动备份, 不设置交换文件
opt.backup = false
opt.swapfile = false
-- 开启换行
opt.wrap = true
-- 单词边界换行
opt.linebreak = true
-- wrap 换行缩进对齐
opt.breakindent = true
-- 换行显示标记
opt.showbreak = '↪ '

-- 自动读取文件修改结果
opt.autoread = false

-- 持久化撤销
opt.undofile = true
opt.undodir = vim.fn.stdpath('cache') .. '/undodir'

-- vim 保存 1000 条文件记录
opt.viminfo = "!,'10000,<50,s10,h"

-- 设置命令行高度
opt.cmdheight = 0

-- 刷新交换文件所需的毫秒数
opt.updatetime = 300

-- 缩短消息长度的标志位列表
opt.shortmess:append('scI')

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

-- 独立配置加载
opt.exrc = true

-- 显示左侧图标指示列
opt.signcolumn = 'yes'

-- 设置光标样式
opt.guicursor = { 'n-v-c:block', 'i-ci-ve:ver25', 'r-cr:hor20', 'o:hor50' }

require('configs.folding')
