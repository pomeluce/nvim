local colors = require('configs.hlyank.colors')
local M = {}

local PRE_STYLE = table.concat({
  'background-color: %s',
  'color: %s',
  "font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace",
  'font-size: 14px',
  'line-height: 1.45',
  'padding: 12px',
  'border-radius: 6px',
  'overflow-x: auto',
}, ';')

local function esc(s)
  s = s:gsub('&', '&amp;')
  s = s:gsub('<', '&lt;')
  s = s:gsub('>', '&gt;')
  s = s:gsub('"', '&quot;')
  return s
end

--- runs:  { {text=string,  color='#rrggbb'},  ... } -> HTML 字符串
function M.runs_to_html(runs)
  local parts = {}
  for _, r in ipairs(runs) do
    local text = esc(r.text)
    if r.color == colors.FG then
      parts[#parts + 1] = text
    else
      parts[#parts + 1] = ('<span style="color: %s">%s</span>'):format(r.color, text)
    end
  end
  local body = table.concat(parts)
  local pre_style = PRE_STYLE:format(colors.BG, colors.FG)
  return ('<pre style="%s">%s</pre>'):format(pre_style, body)
end

local function hex_to_rgb(h)
  h = h:gsub('#', '')
  local n = tonumber(h, 16)
  if not n then return 0, 0, 0 end
  local r = math.floor(n / 65536) % 256
  local g = math.floor(n / 256) % 256
  local b = n % 256
  return r, g, b
end

-- RTF 是 ASCII 格式: 非 ASCII 码位必须以 \uN? Unicode 转义输出, 否则 Word
-- 会把 UTF-8 多字节序列按当前 ANSI 代码页(中文 Windows 即 GBK)误解码成乱码.
-- 按码位迭代: strchars 数字符, strcharpart 取第 i 个字符(LuaJIT 不带 utf8 库,
-- 这里走 vim.fn 的 UTF-8 感知函数;char2nr 取码位).
local function rtf_esc(s)
  local out = {}
  local nchar = vim.fn.strchars(s)
  for i = 0, nchar - 1 do
    local code = vim.fn.char2nr(vim.fn.strcharpart(s, i, 1))
    if code == 10 then
      out[#out + 1] = '\\line\n'
    elseif code == 92 then -- backslash
      out[#out + 1] = '\\\\'
    elseif code == 123 or code == 125 then -- { }
      out[#out + 1] = '\\' .. string.char(code)
    elseif code == 32 then -- space(行首空格保护)
      out[#out + 1] = '\\ '
    elseif code < 128 then
      out[#out + 1] = string.char(code)
    elseif code > 65535 then
      -- 辅助平面(emoji 等, > U+FFFF): RTF \u 只能承载单个 16-bit 值, 必须输出
      -- UTF-16 代理对(高代理 + 低代理), 每半按有符号 16-bit 编码.否则单 \u 会
      -- 把码位截到 BMP 私用区(如 😀 U+1F600 被误读成 U+F600), Word 显示乱码.
      local adj = code - 0x10000
      local hi = 0xD800 + math.floor(adj / 1024)
      local lo = 0xDC00 + (adj % 1024)
      if hi > 32767 then hi = hi - 65536 end
      if lo > 32767 then lo = lo - 65536 end
      out[#out + 1] = ('\\u%d?\\u%d?'):format(hi, lo)
    else
      local u = code
      if u > 32767 then u = u - 65536 end -- RTF \u 是有符号 16-bit
      out[#out + 1] = ('\\u%d?'):format(u)
    end
  end
  return table.concat(out)
end

--- runs -> RTF 字符串(Word 对 RTF 兼容极可靠, 作 HTML 命门回退)
function M.runs_to_rtf(runs)
  -- 收集去重颜色, 建索引
  local idx, order = {}, {}
  for _, r in ipairs(runs) do
    if not idx[r.color] then
      idx[r.color] = #order + 1
      order[#order + 1] = r.color
    end
  end
  local colortbl = {}
  for _, c in ipairs(order) do
    local r, g, b = hex_to_rgb(c)
    colortbl[#colortbl + 1] = ('\\red%d\\green%d\\blue%d;'):format(r, g, b)
  end

  local body = {}
  for _, run in ipairs(runs) do
    body[#body + 1] = ('\\cf%d %s'):format(idx[run.color], rtf_esc(run.text))
  end

  return table.concat({
    '{\\rtf1\\ansi\\deff0',
    '{\\fonttbl{\\f0 Consolas;}}',
    '{\\colortbl;' .. table.concat(colortbl) .. '}', -- 注意: 首项为默认(auto)
    '\\f0\\fs24',
    table.concat(body),
    '}',
  })
end

return M
