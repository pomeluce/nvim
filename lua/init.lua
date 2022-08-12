-- 加载基础配置
require('basic')

-- 加载快捷键配置
require('keybindings')

-- 加载 packer 插件管理
require('plugins')

-- 加载主题样式
require('onedarkpro').setup {
    theme = 'onedark'
}
-- 启动主题
require('onedarkpro').load()

-- 加载 nvim-tree 配置
require('plugin-config/nvim-tree')

-- 加载 bufferline 配置
require('plugin-config/bufferline')

-- 加载 nvim-treesitter 高亮插件
require('plugin-config/nvim-treesitter')
