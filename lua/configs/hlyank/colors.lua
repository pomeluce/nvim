-- 文档主题配色 (Monokai Pro Light, 官方值)
-- 来源: monokai.pro 官网 [data-theme=monokai-pro-light] CSS 变量
local M = {}

M.FG = '#29242a'
M.BG = '#faf4f2'

-- key 同时覆盖 Tree-sitter capture 名(小写)与 Vim 标准 syntax group 名(首字母大写)
local C = {
  -- 关键字 / 控制流 / 修饰 / 标签 (accent1 粉红)
  ['keyword'] = '#e14775',
  ['conditional'] = '#e14775',
  ['repeat'] = '#e14775',
  ['return'] = '#e14775',
  ['Statement'] = '#e14775',
  ['Keyword'] = '#e14775',
  ['Conditional'] = '#e14775',
  ['Repeat'] = '#e14775',
  ['Exception'] = '#e14775',
  ['Label'] = '#e14775',
  ['StorageClass'] = '#e14775',
  -- 函数 / 方法 / 调用 (accent3 金)
  ['function'] = '#cc7a0a',
  ['method'] = '#cc7a0a',
  ['call'] = '#cc7a0a',
  ['Function'] = '#cc7a0a',
  -- 字符串 / 字符 (accent4 绿)
  ['string'] = '#269d69',
  ['character'] = '#269d69',
  ['escape'] = '#269d69',
  ['String'] = '#269d69',
  ['Character'] = '#269d69',
  -- 常量 / 数字 / 布尔 (accent2 橙)
  ['constant'] = '#e16032',
  ['number'] = '#e16032',
  ['boolean'] = '#e16032',
  ['float'] = '#e16032',
  ['Constant'] = '#e16032',
  ['Number'] = '#e16032',
  ['Boolean'] = '#e16032',
  ['Float'] = '#e16032',
  -- 类型 / 类 (accent5 青)
  ['type'] = '#1c8ca8',
  ['class'] = '#1c8ca8',
  ['struct'] = '#1c8ca8',
  ['typedef'] = '#1c8ca8',
  ['builtin_type'] = '#1c8ca8',
  ['Type'] = '#1c8ca8',
  ['Structure'] = '#1c8ca8',
  ['Typedef'] = '#1c8ca8',
  -- 注释 (dimmed3 灰)
  ['comment'] = '#a59fa0',
  ['Comment'] = '#a59fa0',
  ['SpecialComment'] = '#a59fa0',
  -- 标签 (accent1 粉红)
  ['tag'] = '#e14775',
  ['Tag'] = '#e14775',
  -- 属性 / 参数 / 预处理 (accent6 紫 / accent3 金)
  ['attribute'] = '#7058be',
  ['property'] = '#7058be',
  ['parameter'] = '#7058be',
  ['builtin_variable'] = '#7058be',
  ['PreProc'] = '#cc7a0a',
  ['Define'] = '#cc7a0a',
  ['Include'] = '#cc7a0a',
  ['Macro'] = '#cc7a0a',
  -- 特殊 (accent2 橙)
  ['Special'] = '#e16032',
  -- 运算符 (accent1 粉红)
  ['operator'] = '#e14775',
  ['keyword_operator'] = '#e14775',
  ['Operator'] = '#e14775',
  -- 标识符 / 变量 / 构造器
  ['Identifier'] = '#29242a',
  ['variable'] = '#706b6e', -- dimmed1 灰, 减少黑压压
  ['variable.parameter'] = '#7058be', -- accent6 紫, 精确键避免被 variable 前缀(灰)遮蔽
  ['variable.builtin'] = '#e16032', -- accent2, true/false/null/self
  ['constructor'] = '#1c8ca8', -- accent5 青, 构造器/类名
  -- 标点 (dimmed2 中灰, 减黑压压)
  ['punctuation'] = '#918c8e',
  ['delimiter'] = '#918c8e',
  ['bracket'] = '#918c8e',
  ['Delimiter'] = '#918c8e',
}

--- 查表: 命中返回映射色, 未命中/nil/空串返回 M.FG.
--- capture 常带子类型(keyword.return / function.call / variable.builtin / tag.delimiter):
--- 先精确查, 再按第一段前缀匹配, 避免这些 token 落到默认 FG(黑色).
function M.resolve(name)
  if name == nil or name == '' then return M.FG end
  if C[name] then return C[name] end
  local prefix = name:match('^([^.]+)')
  if prefix and C[prefix] then return C[prefix] end
  return M.FG
end

return M
