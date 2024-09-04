require('user.core.globals') -- 全局配置
require('user.configs') -- 插件配置
require('user.core.setup') -- 插件管理
require('user.core.options') -- options 配置
require('user.core.autocmds') -- 自动命令
require('user.core.funcutil') -- 函数配置

vim.schedule(function()
  require('user.core.keymaps') -- 加载快捷键
end)
