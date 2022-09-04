-- 加载基础配置
require('basic')
-- 加载快捷键配置
require('keybindings')
-- 加载 packer 插件管理
require('plugins')
-- 主题设置
require("colorscheme")
-- 自动命令
require("autocmds")

-- >>> 加载插件配置 <<<
-- 加载 nvim-tree 配置
require("plugin-config.nvim-tree")
-- 加载状态栏装饰插件
require("plugin-config.lualine")
-- 加载 bufferline 配置
require("plugin-config.bufferline")
-- 加载 nvim-treesitter 高亮插件
require("plugin-config.nvim-treesitter")
-- 加载 dashborad 启动面板插件
require("plugin-config.dashboard")
-- 加载 project 项目管理插件
require("plugin-config.project")
-- 加载 blank 空行缩进插件
require("plugin-config.indent-blankline")
-- 加载 surround 插件配置
require("plugin-config.surround")
-- 加载 comment 注释快捷键
require("plugin-config.comment")
-- 加载 pairs 括号补全
require("plugin-config.nvim-autopairs")
