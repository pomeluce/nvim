-- ==============================================================
-- BlockComment 模块 — 块注释 toggle(基于 treesitter 子语言感知)
-- ==============================================================
local M = {}

---@class BcDelimiter
---@field left  string
---@field right string
---@field style string|nil  -- 'line' = 独占上下行, nil/'inline' = 同行包裹

-- filetype → 块注释定界符
---@type table<string, BcDelimiter>
M.ft_delimiters = {
  lua = { left = '--[[ ', right = ' ]]' },
  python = { left = '"""', right = '"""', style = 'line' },
  javascript = { left = '/* ', right = ' */' },
  javascriptreact = { left = '/* ', right = ' */' },
  typescript = { left = '/* ', right = ' */' },
  typescriptreact = { left = '/* ', right = ' */' },
  vue = { left = '<!-- ', right = ' -->' },
  html = { left = '<!-- ', right = ' -->' },
  xml = { left = '<!-- ', right = ' -->' },
  xhtml = { left = '<!-- ', right = ' -->' },
  mjml = { left = '<!-- ', right = ' -->' },
  markdown = { left = '<!-- ', right = ' -->' },
  mdx = { left = '<!-- ', right = ' -->' },
  css = { left = '/* ', right = ' */' },
  scss = { left = '/* ', right = ' */' },
  less = { left = '/* ', right = ' */' },
  sass = { left = '/* ', right = ' */' },
  c = { left = '/* ', right = ' */' },
  cpp = { left = '/* ', right = ' */' },
  cuda = { left = '/* ', right = ' */' },
  objc = { left = '/* ', right = ' */' },
  objcpp = { left = '/* ', right = ' */' },
  cs = { left = '/* ', right = ' */' },
  java = { left = '/* ', right = ' */' },
  kotlin = { left = '/* ', right = ' */' },
  scala = { left = '/* ', right = ' */' },
  dart = { left = '/* ', right = ' */' },
  php = { left = '/* ', right = ' */' },
  rust = { left = '/* ', right = ' */' },
  go = { left = '/* ', right = ' */' },
  swift = { left = '/* ', right = ' */' },
  zig = { left = '/* ', right = ' */' },
  vala = { left = '/* ', right = ' */' },
  ruby = { left = '=begin', right = '=end', style = 'line' },
  sh = { left = ": '", right = "'" },
  bash = { left = ": '", right = "'" },
  zsh = { left = ": '", right = "'" },
  fish = { left = ": '", right = "'" },
  haskell = { left = '{- ', right = ' -}' },
  lhs = { left = '{- ', right = ' -}' },
  cmake = { left = '#[[ ', right = ' ]]' },
  terraform = { left = '/* ', right = ' */' },
  hcl = { left = '/* ', right = ' */' },
  nix = { left = '/* ', right = ' */' },
  graphql = { left = '/* ', right = ' */' },
  sql = { left = '/* ', right = ' */' },
}

-- treesitter 注入语言 → 定界符(用于 Vue / JSX/TSX 子语言区域感知)
---@type table<string, BcDelimiter>
M.embedded_delimiters = {
  html = { left = '<!-- ', right = ' -->' },
  vue = { left = '<!-- ', right = ' -->' },
  css = { left = '/* ', right = ' */' },
  scss = { left = '/* ', right = ' */' },
  jsx = { left = '{/* ', right = ' */}' },
  tsx = { left = '{/* ', right = ' */}' },
  javascript = { left = '/* ', right = ' */' },
  typescript = { left = '/* ', right = ' */' },
}

-- 获取当前位置的块注释定界符
---@return BcDelimiter|nil
function M.get_delimiters()
  local ft = vim.bo.filetype

  -- 1) 优先 treesitter 子语言检测(覆盖 html/vue/jsx/tsx 内嵌语言)
  local ok, node = pcall(vim.treesitter.get_node)
  if ok and node then
    ---@diagnostic disable-next-line: undefined-field
    local ok2, lang = pcall(function() return node:lang() end)
    if ok2 and lang and M.embedded_delimiters[lang] then return M.embedded_delimiters[lang] end
  end

  -- 2) treesitter 不可用时, 对 HTML 做文本级回退扫描 <style>/<script> 标签
  if ft == 'html' then
    local cline = vim.fn.line('.')
    for l = cline, 1, -1 do
      local line = vim.fn.getline(l)
      if line:find('<style[>%s]') then return M.embedded_delimiters.css end
      if line:find('<script[>%s]') then
        if line:find('type%s*=%s*["\']text/css') then return M.embedded_delimiters.css end
        if line:find('lang%s*=%s*["\']ts') then return M.embedded_delimiters.typescript end
        return M.embedded_delimiters.javascript
      end
      -- 遇到其他开始标签或闭合标签终止扫描
      if line:find('</style>') or line:find('</script>') then break end
      if line:find('<%w+[>%s]') and not line:find('<style') and not line:find('<script') then break end
    end
  end

  return M.ft_delimiters[ft]
end

-- 回退: 无块注释语言, 用 commentstring 按行前缀注释
---@param line_start integer
---@param line_end integer
function M.toggle_block_fallback(line_start, line_end)
  local cs = vim.bo.commentstring
  if not cs or cs == '' then cs = '-- %s' end
  local prefix = cs:gsub('%%s', '')
  local prefix_trimmed = prefix:gsub('%s+$', '')
  local all_commented = true

  for l = line_start, line_end do
    local line = vim.fn.getline(l)
    if line:find('^%s*' .. vim.pesc(prefix_trimmed), 1) == nil then
      all_commented = false
      break
    end
  end

  for l = line_start, line_end do
    local line = vim.fn.getline(l)
    if all_commented then
      local new_line = line:gsub('^(%s*)' .. vim.pesc(prefix), '%1', 1)
      if new_line == line then new_line = line:gsub('^(%s*)' .. vim.pesc(prefix_trimmed) .. '%s*', '%1', 1) end
      vim.fn.setline(l, new_line)
    else
      local indent = line:match('^(%s*)') or ''
      local rest = line:sub(#indent + 1)
      vim.fn.setline(l, indent .. prefix .. rest)
    end
  end
end

-- 核心: 块注释 toggle
---@param line_start integer 1-based 起始行
---@param line_end integer 1-based 结束行
function M.toggle_block_comment(line_start, line_end)
  if line_start > line_end then
    line_start, line_end = line_end, line_start
  end

  local delims = M.get_delimiters()
  if not delims then
    M.toggle_block_fallback(line_start, line_end)
    return
  end

  local left = delims.left
  local right = delims.right
  -- 定界符独占上下行（由 ft_delimiters 中的 style = 'line' 控制）
  local is_line_delim = (delims.style == 'line')
  -- HTML 类注释需要转义内容中的 --> 防止提前终止注释
  local is_html_comment = (not is_line_delim and right:find('%-%->') ~= nil)

  local first_line = vim.fn.getline(line_start)
  local last_line = vim.fn.getline(line_end)

  -- 检测是否已被块注释包裹
  local is_commented = false
  local delims_at_edges = false -- 定界符是选中区的首尾行(而非上下方)
  if is_line_delim then
    local prev_line = line_start > 1 and vim.fn.getline(line_start - 1) or ''
    local last_line_num = vim.fn.line('$')
    local next_line = line_end < last_line_num and vim.fn.getline(line_end + 1) or ''
    -- 情况 A: 定界符在选中区上方/下方(用户只选了内容)
    if prev_line:find('^%s*' .. vim.pesc(left) .. '%s*$') and next_line:find('^%s*' .. vim.pesc(right) .. '%s*$') then
      is_commented = true
    -- 情况 B: 定界符就是选中区的首行和尾行(用户选中了包括 """ 的全部行)
    elseif line_start ~= line_end and first_line:find('^%s*' .. vim.pesc(left) .. '%s*$') and last_line:find('^%s*' .. vim.pesc(right) .. '%s*$') then
      is_commented = true
      delims_at_edges = true
    end
  else
    local left_pattern = '^%s*' .. vim.pesc(left)
    local right_pattern = vim.pesc(right) .. '%s*$'
    if first_line:find(left_pattern) and last_line:find(right_pattern) then is_commented = true end
  end

  if is_commented then
    -- 取消注释
    if is_line_delim then
      local buf = vim.api.nvim_get_current_buf()
      if delims_at_edges then
        vim.fn.deletebufline(buf, line_end)
        vim.fn.deletebufline(buf, line_start)
      else
        vim.fn.deletebufline(buf, line_end + 1)
        vim.fn.deletebufline(buf, line_start - 1)
      end
    else
      -- HTML 类注释: 先还原转义(--&gt; → -->, &lt;!-- → <!--)
      if is_html_comment then
        for l = line_start, line_end do
          local line = vim.fn.getline(l)
          local restored = line:gsub('%-%-&gt;', '-->'):gsub('&lt;!%-%-', '<!--')
          if restored ~= line then vim.fn.setline(l, restored) end
        end
      end
      if line_start == line_end then
        local content = vim.fn.getline(line_start)
        content = content:gsub('^(%s*)' .. vim.pesc(left), '%1', 1)
        content = content:gsub(vim.pesc(right) .. '%s*$', '', 1)
        vim.fn.setline(line_start, content)
      else
        local new_first = first_line:gsub('^(%s*)' .. vim.pesc(left), '%1', 1)
        local new_last = vim.fn.getline(line_end):gsub(vim.pesc(right) .. '%s*$', '', 1)
        vim.fn.setline(line_start, new_first)
        vim.fn.setline(line_end, new_last)
      end
    end
  else
    -- 添加注释
    if is_line_delim then
      vim.fn.appendbufline(vim.api.nvim_get_current_buf(), line_start - 1, left)
      vim.fn.appendbufline(vim.api.nvim_get_current_buf(), line_end + 1, right)
    else
      -- HTML 类注释: 先转义内容中的 <!-- 和 -->
      if is_html_comment then
        for l = line_start, line_end do
          local line = vim.fn.getline(l)
          -- 先转义 <!-- 再转义 -->(顺序重要)
          local escaped = line:gsub('<!%-%-', '&lt;!--'):gsub('%-%->', '--&gt;')
          if escaped ~= line then vim.fn.setline(l, escaped) end
        end
        -- 重新读取首尾行(可能已被转义修改)
        first_line = vim.fn.getline(line_start)
        last_line = vim.fn.getline(line_end)
      end
      if line_start == line_end then
        local indent = first_line:match('^(%s*)') or ''
        local rest = first_line:sub(#indent + 1)
        local trimmed = rest:gsub('%s+$', '')
        vim.fn.setline(line_start, indent .. left .. trimmed .. right)
      else
        local indent_first = first_line:match('^(%s*)') or ''
        local content_first = first_line:sub(#indent_first + 1)
        vim.fn.setline(line_start, indent_first .. left .. content_first)

        local new_last = last_line:gsub('%s+$', '')
        vim.fn.setline(line_end, new_last .. right)
      end
    end
  end
end

return M
