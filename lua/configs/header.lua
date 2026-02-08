local M = {}

-- 映射
local ft_map = { typescript = 'javascript' }

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

local function read_template(p)
  if not p then return nil end
  if vim.fn.filereadable(p) == 0 then return nil end
  return table.concat(vim.fn.readfile(p), '\n')
end

local function replace_placeholders(tpl)
  local filename = vim.fn.fnamemodify(vim.fn.expand('%:t'), ':r')
  local user = os.getenv('USER') or os.getenv('USERNAME') or 'Your Name'

  local frt = get_file_creation_time()

  local function date_for(fmt) return frt and os.date(fmt, frt) or os.date(fmt) end

  local today = date_for('%Y-%m-%d')
  local time = date_for('%H:%M:%S')

  tpl = tpl:gsub('{%s*FILE_NAME%s*}', filename):gsub('{%s*USER%s*}', user):gsub('{%s*DATE%s*}', today):gsub('{%s*TIME%s*}', time)

  -- 支持 {DATE:<fmt>} 形式
  tpl = tpl:gsub('{%s*DATE:([^}]+)%s*}', function(fmt) return date_for(fmt:gsub('^%s+', ''):gsub('%s+$', '')) end)

  -- 支持 {TIME:<fmt>} 形式
  tpl = tpl:gsub('{%s*TIME:([^}]+)%s*}', function(fmt) return date_for(fmt:gsub('^%s+', ''):gsub('%s+$', '')) end)

  return tpl
end

M.filetype = { 'python', 'javascript', 'typescript' }

---@param args vim.api.keyset.create_autocmd.callback_args
function M.callback(args)
  local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
  local is_empty = #lines == 1 and lines[1] == ''
  if not is_empty then return end

  -- 获取文件类型
  local ft = vim.api.nvim_get_option_value('filetype', { buf = args.buf }) or ''
  if ft_map[ft] then ft = ft_map[ft] end

  -- 获取模板路径
  local path = string.format('%s/tmpls/%s.tmpl', vim.fn.stdpath('config'), ft)
  -- 获取模板内容
  local tpl = read_template(path)
  if not tpl then return end

  -- 替换占位符
  local rendered = replace_placeholders(tpl)
  local content = vim.split(rendered, '\n', { plain = true })
  vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, content)
end

return M
