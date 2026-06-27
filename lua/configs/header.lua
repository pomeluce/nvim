local M = {}

-- ft 别名映射
local ft_map = {
  typescript = 'javascript',
  javascriptreact = 'javascript',
  typescriptreact = 'javascript',
  cpp = 'c',
  sh = 'bash',
  zsh = 'bash',
}

-- 项目标记文件(用于 package 推导, Task 3 使用)
local PROJECT_MARKERS = {
  java = { 'pom.xml', 'build.gradle', 'build.gradle.kts' },
  kotlin = { 'pom.xml', 'build.gradle', 'build.gradle.kts' },
  scala = { 'pom.xml', 'build.gradle', 'build.sbt' },
  go = { 'go.mod' },
  csharp = { '*.csproj', '*.sln' },
}

-- source root(相对项目标记目录)
local SOURCE_ROOTS = {
  java = 'src/main/java',
  kotlin = 'src/main/kotlin',
  scala = 'src/main/scala',
  go = '.',
  csharp = '.',
}

---向上查找项目标记文件, 返回项目根目录路径
---@param start_path string 文件路径
---@param markers string[] 标记文件名列表(支持 *.ext 通配符)
---@return string|nil
local function find_project_root(start_path, markers)
  local dir = vim.fn.fnamemodify(start_path, ':h')
  while dir and dir ~= '/' and dir ~= '' do
    for _, marker in ipairs(markers) do
      if marker:match('^%*%.') then
        -- 通配符模式：如 *.csproj
        local matches = vim.fn.glob(dir .. '/' .. marker, false, true)
        if #matches > 0 then return dir end
      else
        -- 精确文件名
        local marker_path = dir .. '/' .. marker
        if vim.fn.filereadable(marker_path) == 1 then return dir end
      end
    end
    local parent = vim.fn.fnamemodify(dir, ':h')
    if parent == dir then break end
    dir = parent
  end
  return nil
end

---根据文件路径和语言自动推导 package/namespace
---@param ft string 文件类型
---@param filepath string 文件绝对路径
---@return string|nil 推导出的 package 名, 失败返回 nil
function M.derive_package(ft, filepath)
  if not filepath then return nil end
  local markers = PROJECT_MARKERS[ft]
  if not markers then return nil end

  local source_root_rel = SOURCE_ROOTS[ft]
  if not source_root_rel then return nil end

  local project_root = find_project_root(filepath, markers)
  if not project_root then return nil end

  local source_root = source_root_rel == '.' and project_root or (project_root .. '/' .. source_root_rel)

  local dir = vim.fn.fnamemodify(filepath, ':h')

  -- 检查文件是否在 source root 之下
  local escaped = vim.pesc(source_root)
  if dir ~= source_root and not dir:match('^' .. escaped .. '/') then return nil end

  local rel = dir:sub(#source_root + 2) -- skip source_root + trailing "/"
  if rel == '' or rel == dir then return nil end

  if ft == 'go' then
    -- Go: package 是目录名(单层)
    return vim.fn.fnamemodify(rel, ':t')
  else
    -- Java/Kotlin/Scala/C#: 完整目录路径, / → .
    return (rel:gsub('/', '.'))
  end
end

M.defaults = {
  python = [[
"""
author      : {USER}
version     : 1.0
date        : {DATE} {TIME}
module      : {FILE_NAME}
description : (TODO: 描述该模块的功能)
"""
]],

  lua = [[
-- author      : {USER}
-- version     : 1.0
-- date        : {DATE} {TIME}
-- module      : {FILE_NAME}
-- description : (TODO: 描述该模块的功能)
]],

  javascript = [[
/**
 * author      : {USER}
 * version     : 1.0
 * date        : {DATE} {TIME}
 * file        : {FILE_NAME}
 * description : (TODO: 描述该文件的功能)
 */
]],

  java = [[
package {PACKAGE};


/**
 * @author : {USER}
 * @version : 1.0
 * @date : {DATE} {TIME}
 * @className : {CLASS}
 * @description : (TODO: 一句话描述该类的功能)
 */
public class {CLASS} {

}
]],

  kotlin = [[
package {PACKAGE};


/**
 * @author : {USER}
 * @version : 1.0
 * @date : {DATE} {TIME}
 * @className : {CLASS}
 * @description : (TODO: 一句话描述该类的功能)
 */
class {CLASS} {

}
]],

  scala = [[
package {PACKAGE};


/**
 * @author : {USER}
 * @version : 1.0
 * @date : {DATE} {TIME}
 * @className : {CLASS}
 * @description : (TODO: 一句话描述该类的功能)
 */
class {CLASS} {

}
]],

  go = [[
package {PACKAGE}


// author      : {USER}
// version     : 1.0
// date        : {DATE} {TIME}
// file        : {FILE_NAME}
// description : (TODO: 描述该文件的功能)
]],

  csharp = [[
namespace {PACKAGE};


/// <summary>
/// author      : {USER}
/// version     : 1.0
/// date        : {DATE} {TIME}
/// className   : {CLASS}
/// description : (TODO: 一句话描述该类的功能)
/// </summary>
public class {CLASS} {

}
]],

  c = [[
/*
 * author      : {USER}
 * version     : 1.0
 * date        : {DATE} {TIME}
 * file        : {FILE_NAME}
 * description : (TODO: 描述该文件的功能)
 */
]],

  rust = [[
// author      : {USER}
// version     : 1.0
// date        : {DATE} {TIME}
// file        : {FILE_NAME}
// description : (TODO: 描述该文件的功能)
]],

  ruby = [[
# author      : {USER}
# version     : 1.0
# date        : {DATE} {TIME}
# file        : {FILE_NAME}
# description : (TODO: 描述该文件的功能)
]],

  bash = [[
# author      : {USER}
# version     : 1.0
# date        : {DATE} {TIME}
# file        : {FILE_NAME}
# description : (TODO: 描述该脚本的功能)
]],

  swift = [[
// author      : {USER}
// version     : 1.0
// date        : {DATE} {TIME}
// file        : {FILE_NAME}
// description : (TODO: 描述该文件的功能)
]],

  zig = [[
// author      : {USER}
// version     : 1.0
// date        : {DATE} {TIME}
// file        : {FILE_NAME}
// description : (TODO: 描述该文件的功能)
]],
}

local function get_file_creation_time()
  local path = vim.fn.expand('%:p')
  if path == '' then return nil end
  if vim.fn.filereadable(path) == 0 then return nil end

  local stat = vim.loop.fs_stat(path)
  if not stat then return nil end

  local ts = stat.birthtime or stat.ctime or stat.mtime
  if not ts then return nil end

  local res = tonumber(ts.sec)
  return res and math.floor(res) or nil
end

---替换模板中的占位符
---@param tpl string 模板字符串
---@param extra? { PACKAGE?: string, CLASS?: string }
---@return string
local function replace_placeholders(tpl, extra)
  extra = extra or {}
  local filename = vim.fn.fnamemodify(vim.fn.expand('%:t'), ':r')
  local user = os.getenv('USER') or os.getenv('USERNAME') or 'Your Name'

  local frt = get_file_creation_time()
  local function date_for(fmt) return frt and os.date(fmt, frt) or os.date(fmt) end

  local today = date_for('%Y-%m-%d')
  local time = date_for('%H:%M:%S')
  local package = extra.PACKAGE or ''
  local class = extra.CLASS or filename

  -- {PACKAGE} 特殊处理：为空时整行移除
  tpl = tpl:gsub('([^\n]*{%s*PACKAGE%s*}[^\n]*\n?)', function(line)
    if package == '' then return '' end
    return line:gsub('{%s*PACKAGE%s*}', package)
  end)

  -- 其余占位符直接替换
  tpl = tpl
    :gsub('{%s*CLASS%s*}', class)
    :gsub('{%s*FILE_NAME%s*}', filename)
    :gsub('{%s*USER%s*}', user)
    :gsub('{%s*DATE:([^}]+)%s*}', function(fmt) return date_for(fmt:gsub('^%s+', ''):gsub('%s+$', '')) end)
    :gsub('{%s*DATE%s*}', today)
    :gsub('{%s*TIME:([^}]+)%s*}', function(fmt) return date_for(fmt:gsub('^%s+', ''):gsub('%s+$', '')) end)
    :gsub('{%s*TIME%s*}', time)

  -- PACKAGE 为空时清理多余空行和前导空行
  if package == '' then
    tpl = tpl:gsub('^\n+', '') -- 去除 {PACKAGE} 行删除后留下的前导空行
    tpl = tpl:gsub('\n\n\n+', '\n\n') -- 折叠多余空行
  end

  return tpl
end

M.filetype = vim.tbl_keys(M.defaults)
-- 补充 ft_map 别名，确保 autocmd 对 TypeScript/C++/Shell 等也能触发
for ft, _ in pairs(ft_map) do
  M.filetype[#M.filetype + 1] = ft
end

---@param args vim.api.keyset.create_autocmd.callback_args
function M.callback(args)
  local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
  local is_empty = #lines == 1 and lines[1] == ''
  if not is_empty then return end

  -- 获取文件类型
  local ft = vim.api.nvim_get_option_value('filetype', { buf = args.buf }) or ''
  if ft_map[ft] then ft = ft_map[ft] end

  -- 合并用户配置和默认模板
  local settings = require('settings')
  local templates = vim.tbl_deep_extend('force', {}, M.defaults, settings.header or {})

  -- 获取模板
  local tpl = templates[ft]
  if not tpl then return end

  -- 推导 package
  local filepath = vim.fn.expand('%:p')
  local package = M.derive_package(ft, filepath)

  -- 替换占位符
  local rendered = replace_placeholders(tpl, { PACKAGE = package })
  local content = vim.split(rendered, '\n', { plain = true })
  vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, content)
end

return M
