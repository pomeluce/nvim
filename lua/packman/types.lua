---@class packman.PluginSpec
---@field [1]? string 短格式 src ('owner/repo')
---@field src? string 完整 Git URL
---@field name? string 插件名 (默认从 src 推断)
---@field enabled? boolean 是否启用 (默认 true)
---@field version? string|vim.VersionRange semver range 或 git branch 名
---@field opts? table 传递给 setup() 的选项
---@field config? function 自定义配置函数
---@field main? string 覆盖推断的 Lua 模块名
---@field event? string|string[] 延迟加载事件
---@field keys? string|table[] 延迟加载按键
---@field cmd? string|string[] 延迟加载命令
---@field ft? string|string[] 延迟加载文件类型
---@field dependencies? string[]|packman.PluginSpec|packman.PluginSpec[] 依赖插件

---@class packman.ImportSpec
---@field import string 要导入的模块路径

---@alias packman.SpecItem packman.PluginSpec|packman.ImportSpec

return {}
