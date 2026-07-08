local colors = require('configs.hlyank.colors')
local M = {}

-- 非"视觉颜色"类 capture,取色时跳过
local NON_COLOR = {
  ['injection'] = true,
  ['injection.language'] = true,
  ['conceal'] = true,
  ['spell'] = true,
  ['exclude'] = true,
}

-- Tree-sitter 路径: 返回颜色 hex 或 nil.row0/col0 为 0-based.
local function color_from_ts(buf, row0, col0)
  local ft = vim.bo[buf].filetype
  if ft == nil or ft == '' then return nil end
  -- filetype(typescriptreact)≠ parser lang(tsx);用 get_lang 做映射,否则 tsx 等取色全失败
  local lang = vim.treesitter.language.get_lang(ft) or ft
  local ok, parser = pcall(vim.treesitter.get_parser, buf, lang)
  if not ok or not parser then return nil end
  local ok2, caps = pcall(vim.treesitter.get_captures_at_pos, buf, row0, col0)
  if not ok2 or not caps or #caps == 0 then return nil end
  local best_color, best_pri = nil, -1
  for _, cap in ipairs(caps) do
    local name = cap.capture or cap.name
    if name and not NON_COLOR[name] then
      local pri = (cap.metadata and cap.metadata.priority) or 100
      if pri >= best_pri then
        best_pri = pri
        best_color = colors.resolve(name)
      end
    end
  end
  return best_color
end

-- Vim syntax 路径: row1/col1 为 1-based.
local function color_from_syntax(row1, col1)
  local id = vim.fn.synID(row1, col1, 1)
  if not id or id == 0 then return nil end
  local group = vim.fn.synIDattr(vim.fn.synIDtrans(id), 'name')
  if group and group ~= '' then return colors.resolve(group) end
  return nil
end

-- 默认取色: TS -> syntax -> FG.row1/col1 为 1-based.
local function color_at(buf, row1, col1)
  local c = color_from_ts(buf, row1 - 1, col1 - 1)
  if c then return c end
  c = color_from_syntax(row1, col1)
  if c then return c end
  return colors.FG
end

-- 一次性构建 char->color 映射(O(captures) 而非 O(chars)).用 iter_captures
-- 遍历 highlights 查询一次,按 priority 升序填表(高优先级覆盖低);同优先级
-- 按捕获顺序(idx)后覆盖先 —— 与 per-char get_captures_at_pos 的 >= 语义一致.
-- 任一步失败(无 parser / 无 highlights 查询)返回 nil,调用方回退到逐字符 color_at.
-- srow/erow 为 1-based 含首尾.返回 map[row0][col0]=color 或 nil.
local function build_ts_color_map(buf, srow, erow)
  local ft = vim.bo[buf].filetype
  if ft == nil or ft == '' then return nil end
  local lang = vim.treesitter.language.get_lang(ft) or ft
  local okp, parser = pcall(vim.treesitter.get_parser, buf, lang)
  if not okp or not parser then return nil end
  parser:parse()
  local okq, query = pcall(vim.treesitter.query.get, lang, 'highlights')
  if not okq or not query then return nil end
  local trees = parser:trees()
  if not trees or trees[1] == nil then return nil end
  local root = trees[1]:root()
  if not root then return nil end

  local ranges, idx = {}, 0
  for cid, node, metadata in query:iter_captures(root, buf, srow - 1, erow) do
    local name = query.captures[cid]
    if name and not NON_COLOR[name] then
      local r1, c1, r2, c2 = node:range() -- 0-based, end-exclusive
      idx = idx + 1
      ranges[idx] = { r1, c1, r2, c2, colors.resolve(name), (metadata and metadata.priority) or 100, idx }
    end
  end
  -- 升序: 低优先级先填, 高优先级覆盖;同优先级按捕获序号(idx)后覆盖先
  table.sort(ranges, function(a, b)
    if a[6] ~= b[6] then return a[6] < b[6] end
    return a[7] < b[7]
  end)

  local map, srow0, erow0 = {}, srow - 1, erow - 1
  for i = 1, idx do
    local rg = ranges[i]
    local r1, c1, r2, c2, color = rg[1], rg[2], rg[3], rg[4], rg[5]
    for row = r1, r2 do
      if row >= srow0 and row <= erow0 then
        local rt = map[row]
        if not rt then
          rt = {}
          map[row] = rt
        end
        local startc = (row == r1) and c1 or 0
        -- 末行用 c2(排他);其余行用大边界,extract_runs 仅查实际列长以内
        local endc_excl = (row == r2) and c2 or 9999
        for col = startc, endc_excl - 1 do
          rt[col] = color
        end
      end
    end
  end
  return map
end

--- 提取 runs.srow/erow 为 1-based 含首尾.color_fn(buf,row1,col1)->color 可选(单测注入).
function M.extract_runs(buf, srow, erow, color_fn)
  local injected = color_fn ~= nil
  color_fn = color_fn or color_at
  -- 默认路径: 一次性构建 TS 颜色映射(O(captures));失败或注入 color_fn 时回退逐字符.
  local ts_map = (not injected) and build_ts_color_map(buf, srow, erow) or nil
  local fn
  if ts_map then
    fn = function(_, row1, col1)
      local rt = ts_map[row1 - 1]
      if rt then
        local c = rt[col1 - 1]
        if c then return c end
      end
      local sc = color_from_syntax(row1, col1)
      return sc or colors.FG
    end
  else
    -- 回退: 逐字符 TS(get_captures_at_pos).预先 parse 一次避免逐字符重复解析.
    pcall(function()
      local ft = vim.bo[buf].filetype
      if ft and ft ~= '' then
        local lang = vim.treesitter.language.get_lang(ft) or ft
        local p = vim.treesitter.get_parser(buf, lang)
        if p then p:parse() end
      end
    end)
    fn = color_fn
  end
  local runs, last = {}, nil
  local function push(text, color)
    if text == '' then return end
    if last and last.color == color then
      last.text = last.text .. text
    else
      last = { text = text, color = color }
      runs[#runs + 1] = last
    end
  end
  for row = srow, erow do
    local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1] or ''
    for col = 1, #line do
      push(line:sub(col, col), fn(buf, row, col))
    end
    push('\n', colors.FG)
  end
  return runs
end

-- 环境检测: WSL 下 WSLg 剪贴板桥不把 wl-copy 的 text/html / application/rtf
-- 翻译成 Windows 的 HTML Format / Rich Text Format(Word 粘贴为纯文本),所以
-- WSL 走 powershell.exe 直写 CF_RTF;原生 Wayland/Niri 走 wl-copy --type text/html.
--- 字符串级检测(可单测注入): /proc/version 含 microsoft(大小写不敏感)即为 WSL.
function M.is_wsl_version(version) return type(version) == 'string' and version:lower():find('microsoft') ~= nil end

-- 模块级缓存: 只读一次 /proc/version.power-shell 启动慢(~1s),不要每次 copy 都探测.
local _wsl_cache
--- 返回当前是否 WSL(布尔).首次调用读 /proc/version 并缓存结果.
function M.is_wsl()
  if _wsl_cache == nil then
    local f = io.open('/proc/version', 'r')
    _wsl_cache = M.is_wsl_version(f and f:read('*a') or '') or false
    if f then f:close() end
  end
  return _wsl_cache
end

-- WSL 下 appendWindowsPath 可能关闭(为避免 zsh 补全卡),powershell.exe 不在 PATH.
-- exepath 查不到时回退常见绝对路径;也支持 vim.g.hlyank_powershell 自定义.缓存结果.
local _ps_cache
function M.find_powershell()
  if _ps_cache ~= nil then return _ps_cache end
  local configured = vim.g.hlyank_powershell
  if configured and vim.fn.executable(configured) == 1 then
    _ps_cache = configured
    return configured
  end
  local p = vim.fn.exepath('powershell.exe')
  if p ~= '' then
    _ps_cache = p
    return p
  end
  local candidates = {
    '/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe',
    '/mnt/c/Program Files/PowerShell/7/pwsh.exe',
  }
  for _, c in ipairs(candidates) do
    if vim.fn.executable(c) == 1 then
      _ps_cache = c
      return c
    end
  end
  _ps_cache = false
  return false
end

--- 写剪贴板: plain 同步写 + 与 " 寄存器作纯文本回退(必做);富文本按环境分流:
--- WSL -> powershell.exe 直写 CF_RTF(绕过 WSLg 桥,Word 原生识别 Rich Text Format);
--- 原生 Wayland -> wl-copy --type text/html(Wayland 把 text/html 翻给浏览器/LibreOffice).
--- 两条富文本路径都走 ASYNC: 不依赖 : wait() 返回值(neovim#37922,SystemObj: wait() 可能
--- 返回 nil),失败时 ERROR notify(不静默).无返回值(copy 不依赖返回值).
function M.write_clipboard(html, rtf, plain)
  vim.fn.setreg('+', plain)
  vim.fn.setreg('"', plain)
  local on_exit = function(obj)
    -- obj may be nil or a result table (neovim#37922)
    if not obj or obj.code ~= 0 then
      vim.schedule(function() vim.notify(('[hlyank] 剪贴板写入失败:  %s'):format((obj and (obj.stderr or obj.code)) or 'nil'), vim.log.levels.ERROR) end)
    end
  end
  -- vim.system 在 spawn 失败(ENOENT,如 interop 关闭 / 二进制不在 PATH)时
  -- 同步抛错而非走 on_exit,pcall 兜住,降级为 ERROR notify(纯文本回退仍生效).
  local ok
  if M.is_wsl() then
    local ps = M.find_powershell()
    if ps then
      -- -STA: Clipboard / DataObject 需要 Single-Threaded Apartment
      -- [Console]: : InputEncoding=UTF8 必须在 ReadToEnd 之前设置: PowerShell 5.1
      -- 默认按系统 ANSI 代码页(中文 Windows 即 GBK)解码 stdin,vim.system 写入的
      -- UTF-8 字节会被错读为乱码写入 CF_RTF.
      -- 原子替换: setreg('+',plain) 先写入 CF_TEXT(纯文本),随后这里用
      -- Clipboard: : SetDataObject($do,$true) 替换整个剪贴板 —— DataObject 同时携带
      -- CF_RTF 和 CF_UNICODETEXT,$true 使其持久化(copy),并清掉 setreg 留下的
      -- CF_TEXT.否则 Word/WordPad 优先粘贴 CF_TEXT → 纯文本无颜色,即使 CF_RTF
      -- 已存在也不会被选中.stdin 承载 rtf 与 plain 两段,以 \0\0HLYANK_SEP\0\0
      -- 分隔(null 字节不可能出现在代码或 RTF 里;RTF 的 \## 只用 ASCII 数字/字母).
      local ps_script =
        [[Add-Type -AssemblyName System.Windows.Forms; [Console]: : InputEncoding = [System.Text.Encoding]: : UTF8; $raw=[Console]: : In.ReadToEnd(); $sep=[char]0+[char]0+'HLYANK_SEP'+[char]0+[char]0; $i=$raw.IndexOf($sep); $rtf=$raw.Substring(0,$i); $plain=$raw.Substring($i+$sep.Length); $do=New-Object System.Windows.Forms.DataObject; $do.SetText($rtf,[System.Windows.Forms.TextDataFormat]: : Rtf); $do.SetText($plain,[System.Windows.Forms.TextDataFormat]: : UnicodeText); [System.Windows.Forms.Clipboard]: : SetDataObject($do,$true)]]
      ok = pcall(vim.system, { ps, '-STA', '-NoProfile', '-Command', ps_script }, { stdin = rtf .. '\0\0HLYANK_SEP\0\0' .. plain, timeout = 10000 }, on_exit)
    else
      -- powershell 未找到(appendWindowsPath 关且非标准路径): 降级 wl-copy + 警告.
      -- 仅当 wl-copy 成功(spawn ok)时才提示 powershell 缺失(降级说明);若
      -- wl-copy 也失败,下方 `if not ok` 已发 ERROR,不再叠加 WARN,避免双重 notify.
      ok = pcall(vim.system, { 'wl-copy', '--type', 'text/html' }, { stdin = html, timeout = 5000 }, on_exit)
      if ok then
        vim.schedule(
          function()
            vim.notify('[hlyank] WSL 未找到 powershell.exe,富文本可能无法粘贴到 Word(可 : let g: hlyank_powershell="/path/to/pwsh" 指定)', vim.log.levels.WARN)
          end
        )
      end
    end
  else
    ok = pcall(vim.system, { 'wl-copy', '--type', 'text/html' }, { stdin = html, timeout = 5000 }, on_exit)
  end
  if not ok then
    vim.schedule(
      function() vim.notify(('[hlyank] 剪贴板后端不可用(%s),仅纯文本已写入'):format(M.is_wsl() and 'powershell.exe' or 'wl-copy'), vim.log.levels.ERROR) end
    )
  end
end

--- 主入口.opts.start_row / opts.end_row 缺省取整个当前 buffer(1-based,含首尾).
function M.copy(opts)
  opts = opts or {}
  local buf = vim.api.nvim_get_current_buf()
  local buftype = vim.bo[buf].buftype
  if buftype ~= '' and buftype ~= 'acwrite' then
    vim.notify(('[hlyank] 不支持的 buffer 类型:  %s'):format(buftype), vim.log.levels.WARN)
    return
  end
  local line_count = vim.api.nvim_buf_line_count(buf)
  local srow = opts.start_row or 1
  local erow = opts.end_row or line_count
  if srow > erow then
    srow, erow = erow, srow
  end
  if srow < 1 then srow = 1 end
  if erow > line_count then erow = line_count end

  local render = require('configs.hlyank.render')
  local runs = M.extract_runs(buf, srow, erow)
  if #runs == 0 then
    vim.notify('[hlyank] 范围为空', vim.log.levels.WARN)
    return
  end

  -- 两种富文本都生成: write_clipboard 按环境选后端(WSL 用 RTF,原生用 HTML).
  local html = render.runs_to_html(runs)
  local rtf = render.runs_to_rtf(runs)

  local lines = vim.api.nvim_buf_get_lines(buf, srow - 1, erow, false)
  local plain = table.concat(lines, '\n') .. '\n'

  M.write_clipboard(html, rtf, plain)
  vim.notify(('[hlyank] 已复制 %d 行(%d 字符)%s'):format(erow - srow + 1, #plain, M.is_wsl() and ' [RTF]' or ''))
end

return M
