local M = {}

local api = vim.api

--- 获取当前 tab 的 buffer 列表
--- @return number[]
local function get_tab_bufs() return vim.t.bufs or {} end

--- 设置当前 tab 的 buffer 列表
--- @param bufs number[]
local function set_tab_bufs(bufs) vim.t.bufs = bufs end

local cur_buf = api.nvim_get_current_buf
local set_buf = api.nvim_set_current_buf

--- 不应该包含在切换列表中的 buftype
local excluded_buftypes = {
  ['terminal'] = true,
  ['prompt'] = true,
  ['popup'] = true,
  ['nofile'] = true,
}

--- 允许显示在 buffer 栏中的特殊 nofile buffer
local included_nofile_names = {
  ['health://'] = true,
}

--- 不应该包含在切换列表中的 filetype
local excluded_filetypes = {
  ['Avante'] = true,
  ['AvanteInput'] = true,
  ['AvanteSelectedFiles'] = true,
  ['neo-tree'] = true,
  ['neo-tree-popup'] = true,
  ['NvimTree'] = true,
  ['aerial'] = true,
  ['dap-repl'] = true,
  ['dapui_console'] = true,
  ['dapui_watches'] = true,
  ['dapui_stacks'] = true,
  ['dapui_breakpoints'] = true,
  ['dapui_scopes'] = true,
  ['DiffviewFiles'] = true,
  ['DiffviewFileHistory'] = true,
  ['fugitive'] = true,
  ['fugitiveblame'] = true,
  ['gitcommit'] = true,
  ['gitrebase'] = true,
  ['NeogitStatus'] = true,
  ['NeogitLog'] = true,
  ['NeogitGitCommandHistory'] = true,
  ['NeogitPopup'] = true,
  ['NeogitCommitSelectView'] = true,
  ['NeogitCommitView'] = true,
  ['NeogitRefsView'] = true,
  ['NeogitStashView'] = true,
  ['toggleterm'] = true,
  ['lazy'] = true,
  ['mason'] = true,
  ['lspinfo'] = true,
  ['help'] = true,
  ['man'] = true,
  ['qf'] = true,
  ['TelescopePrompt'] = true,
  ['TelescopeResults'] = true,
  ['fzf'] = true,
  ['notify'] = true,
  ['noice'] = true,
}

--- 判断 buffer 是否应该包含在切换列表中
--- @param bufnr number
--- @return boolean
local function should_include_buf(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then return false end

  -- 检查 buflisted
  if not vim.api.nvim_get_option_value('buflisted', { buf = bufnr }) then return false end

  -- 检查 buftype
  local buftype = vim.api.nvim_get_option_value('buftype', { buf = bufnr }) or ''
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if excluded_buftypes[buftype] and not (buftype == 'nofile' and included_nofile_names[bufname]) then return false end

  -- 检查 filetype
  local filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr }) or ''
  if excluded_filetypes[filetype] then return false end

  -- 检查是否在浮动窗口中(如果当前窗口是浮动窗口且显示的是这个 buffer)
  local wins = vim.fn.win_findbuf(bufnr)
  for _, winid in ipairs(wins) do
    local win_config = vim.api.nvim_win_get_config(winid)
    -- 如果 buffer 在浮动窗口中, 不包含
    if win_config.relative and win_config.relative ~= '' then return false end
  end

  return true
end

--- 安全地设置 buffer, 带有效性检查
local function safe_set_buf(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then return false end
  local ok, _ = pcall(set_buf, bufnr)
  return ok
end

--- 清理当前 tab 列表中的无效 buffer
--- @return number[]
local function clean_invalid_bufs()
  local bufs = get_tab_bufs()
  local cleaned = {}
  for _, bufnr in ipairs(bufs) do
    if vim.api.nvim_buf_is_valid(bufnr) then table.insert(cleaned, bufnr) end
  end
  set_tab_bufs(cleaned)
  return cleaned
end

--- 获取当前 tab 的有序 buffer 列表，供 tabline 和切换逻辑共用
--- @return number[]
function M.get_bufs() return clean_invalid_bufs() end

--- 获取 buffer 在列表中的索引
--- @param bufnr number
--- @param bufs number[]|nil
--- @return number|nil
local function buf_index(bufnr, bufs)
  if not bufnr then return nil end
  bufs = bufs or get_tab_bufs()
  for i, value in ipairs(bufs) do
    if value == bufnr then return i end
  end
  return nil
end

--- 初始化当前 tab 的 buffer 列表
local function init_tab_bufs()
  if vim.t.bufs then return end
  set_tab_bufs(vim.tbl_filter(function(buf) return api.nvim_buf_is_valid(buf) and vim.fn.buflisted(buf) == 1 end, api.nvim_list_bufs()))
end

init_tab_bufs()

--- 删除 buffer, 如果 buffer 有修改则提示保存
--- @param bufnr number
local function buf_del(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end

  local modified = vim.api.nvim_get_option_value('modified', { buf = bufnr })

  if modified then
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    bufname = bufname == '' and '[No Name]' or vim.fn.fnamemodify(bufname, ':~:.')
    if bufname:match('^/') then bufname = vim.fn.fnamemodify(bufname, ':t') end
    if bufname == '' then bufname = '[No Name]' end
    local choice = vim.fn.confirm('Save changes to "' .. bufname .. '"?', '&Yes\n&No\n&Cancel', 1, 'Question')
    if choice == 1 then
      vim.api.nvim_buf_call(bufnr, function() vim.cmd('silent write') end)
      vim.api.nvim_buf_delete(bufnr, {})
    elseif choice == 2 then
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end
  -- choice == 3 (Cancel) 时不做任何操作
  else
    vim.api.nvim_buf_delete(bufnr, {})
  end
end

--- 按偏移量切换当前 tab 中的 buffer
--- @param offset 1|-1
local function switch_buf(offset)
  local bufs = M.get_bufs()
  if #bufs == 0 then return end

  local current_index = buf_index(cur_buf(), bufs)

  -- 当前 buffer 可能是未参与列表的侧栏或临时窗口。
  if not current_index then
    for _, bufnr in ipairs(bufs) do
      if safe_set_buf(bufnr) then return end
    end
    return
  end

  for i = 1, #bufs do
    local index = (current_index - 1 + offset * i) % #bufs + 1
    if index ~= current_index and safe_set_buf(bufs[index]) then return end
  end
end

--- 切换到下一个 buffer
function M.next_buf() switch_buf(1) end

--- 切换到上一个 buffer
function M.prev_buf() switch_buf(-1) end

--- 关闭 transient buffer，并尽量返回来源 buffer
--- @param bufnr number
--- @return boolean handled
local function close_transient_buf(bufnr)
  if not vim.b[bufnr].transient then return false end

  local origin = vim.b[bufnr].transient_origin
  if not safe_set_buf(origin) then
    local bufs = get_tab_bufs()
    for i = #bufs, 1, -1 do
      local candidate = bufs[i]
      if candidate ~= bufnr and should_include_buf(candidate) and safe_set_buf(candidate) then break end
    end
  end
  if api.nvim_buf_is_valid(bufnr) then api.nvim_buf_delete(bufnr, { force = true }) end
  vim.cmd('redrawtabline')
  return true
end

--- 多 tab 时沿用原有策略：当前 tab buffer 较少时切走后再删除
--- @param bufnr number
--- @return boolean handled
local function close_buf_with_multiple_tabs(bufnr)
  local tabs = api.nvim_list_tabpages()
  if #tabs <= 1 then return false end

  local bufs = get_tab_bufs()
  if #bufs <= 2 then
    local current_tab = api.nvim_get_current_tabpage()
    local target_tab
    for _, tab in ipairs(tabs) do
      if tab ~= current_tab then target_tab = tab end
    end
    vim.cmd('tabnext ' .. target_tab)
    if api.nvim_tabpage_is_valid(current_tab) then buf_del(bufnr) end
    vim.cmd('redrawtabline')
  end
  return true
end

--- 切换到列表中目标 buffer 之前的有效 buffer
--- @param bufnr number
--- @return boolean
local function switch_to_previous_buf(bufnr)
  local bufs = M.get_bufs()
  local current_index = buf_index(bufnr, bufs)
  if not current_index then return false end

  for i = 1, #bufs do
    local index = (current_index - i - 1) % #bufs + 1
    if index ~= current_index and safe_set_buf(bufs[index]) then return true end
  end
  return false
end

--- 关闭普通 buffer 前切换到合适的窗口或 buffer
--- @param bufnr number
local function close_regular_buf(bufnr)
  local bufhidden = vim.bo[bufnr].bufhidden
  local bufs = M.get_bufs()
  local index = buf_index(bufnr, bufs)
  local win_config = api.nvim_win_get_config(0)

  if win_config.zindex then
    vim.cmd('bw')
    return
  elseif index and #bufs > 1 then
    if not switch_to_previous_buf(bufnr) then vim.cmd('enew') end
  elseif not vim.bo[bufnr].buflisted then
    local fallback = bufs[#bufs]
    if fallback and api.nvim_buf_is_valid(fallback) then
      local winid = vim.fn.bufwinid(fallback)
      api.nvim_set_current_win(winid ~= -1 and winid or 0)
      safe_set_buf(fallback)
    end
    vim.cmd('bw' .. bufnr)
    return
  else
    vim.cmd('enew')
  end

  if bufhidden ~= 'delete' then buf_del(bufnr) end
end

--- 关闭 buffer
--- @param bufnr number|nil buffer number, nil 则关闭当前 buffer
function M.close_buf(bufnr)
  bufnr = bufnr or cur_buf()

  if not api.nvim_buf_is_valid(bufnr) then return end
  if close_transient_buf(bufnr) then return end
  if close_buf_with_multiple_tabs(bufnr) then return end

  if vim.bo[bufnr].buftype == 'terminal' then
    vim.cmd(vim.bo[bufnr].buflisted and 'set nobl | enew' or 'hide')
  else
    close_regular_buf(bufnr)
  end

  vim.cmd('redrawtabline')
end

--- 关闭多个 buffer
--- @param include_cur_buf boolean 是否关闭当前 buffer
function M.close_bufs(include_cur_buf)
  local bufs = clean_invalid_bufs()
  if #bufs == 0 then return end

  -- 创建副本以避免在迭代过程中修改原表
  local bufs_to_close = {}
  local cur = cur_buf()
  for _, buf in ipairs(bufs) do
    if include_cur_buf ~= false or buf ~= cur then table.insert(bufs_to_close, buf) end
  end
  for _, buf in ipairs(bufs_to_close) do
    if vim.api.nvim_buf_is_valid(buf) then M.close_buf(buf) end
  end
end

--- 检查 buffer 是否为空 buffer(可以安全关闭)
--- @param buf number buffer number
--- @return boolean
function M.empty_buf(buf)
  if not api.nvim_buf_is_valid(buf) then return false end

  local name = api.nvim_buf_get_name(buf)
  if name ~= '' then return false end
  if api.nvim_get_option_value('modified', { buf = buf }) then return false end
  local allowed_buftypes = { [''] = true, ['nofile'] = true }
  local allowed_filetypes = { [''] = true }
  local buftype = api.nvim_get_option_value('buftype', { buf = buf }) or ''
  local filetype = api.nvim_get_option_value('filetype', { buf = buf }) or ''
  if not allowed_buftypes[buftype] then return false end
  if not allowed_filetypes[filetype] then return false end

  return true
end

--- 维护当前 tab 的 buffer 列表
--- @param args vim.api.keyset.create_autocmd.callback_args
local function track_buf(args)
  if not api.nvim_buf_is_valid(args.buf) then return end

  local bufs = get_tab_bufs()
  if not vim.tbl_contains(bufs, args.buf) then
    local should_add = args.event == 'BufAdd' or args.event == 'BufEnter'
    if args.event == 'TabNew' then should_add = cur_buf() == args.buf end
    if should_add and should_include_buf(args.buf) then table.insert(bufs, args.buf) end
  end

  -- 新文件替换启动时的空 buffer 后，不再保留这个占位项。
  if args.event == 'BufAdd' and #bufs > 0 then
    local first_buf = bufs[1]
    if api.nvim_buf_is_valid(first_buf) then
      local name = api.nvim_buf_get_name(first_buf)
      local modified = api.nvim_get_option_value('modified', { buf = first_buf })
      if name == '' and not modified then table.remove(bufs, 1) end
    end
  end

  set_tab_bufs(bufs)

  -- 某些特殊 buffer（如 health://）在 BufEnter 后才设置名称和选项。
  if args.event == 'BufAdd' or args.event == 'BufEnter' then
    local bufnr = args.buf
    local tab = api.nvim_get_current_tabpage()
    vim.schedule(function()
      if not api.nvim_tabpage_is_valid(tab) or not api.nvim_buf_is_valid(bufnr) or not should_include_buf(bufnr) then return end
      local tab_bufs = vim.t[tab].bufs or {}
      if not vim.tbl_contains(tab_bufs, bufnr) then
        table.insert(tab_bufs, bufnr)
        vim.t[tab].bufs = tab_bufs
        vim.cmd('redrawtabline')
      end
    end)
  end
end

--- FileType 确定后，移除应被排除的工具 buffer
--- @param bufnr number
local function remove_excluded_buf(bufnr)
  if should_include_buf(bufnr) then return end

  local bufs = get_tab_bufs()
  for i = #bufs, 1, -1 do
    if bufs[i] == bufnr then table.remove(bufs, i) end
  end
  set_tab_bufs(bufs)
end

--- 从所有 tab 的列表中移除已删除的 buffer
--- @param bufnr number
local function remove_buf_from_tabs(bufnr)
  for _, tab in ipairs(api.nvim_list_tabpages()) do
    local bufs = vim.t[tab].bufs
    if bufs then
      for i = #bufs, 1, -1 do
        if bufs[i] == bufnr then table.remove(bufs, i) end
      end
      vim.t[tab].bufs = bufs
    end
  end
end

--- 删除当前 tab 在 BufDelete 后留下的空 buffer
local function close_current_empty_buf()
  local tab = api.nvim_get_current_tabpage()
  local wins = api.nvim_tabpage_list_wins(tab)
  if #wins ~= 1 then return end

  local bufnr = api.nvim_win_get_buf(wins[1])
  if M.empty_buf(bufnr) then M.close_buf(bufnr) end
end

--- TabClosed 后清理遗留的空 buffer
local function close_all_empty_bufs()
  for _, bufnr in ipairs(api.nvim_list_bufs()) do
    if M.empty_buf(bufnr) then M.close_buf(bufnr) end
  end
end

local function setup_autocmds()
  local group = api.nvim_create_augroup('Tabufs', { clear = true })

  api.nvim_create_autocmd({ 'BufAdd', 'BufEnter', 'TabNew' }, {
    group = group,
    callback = track_buf,
  })

  api.nvim_create_autocmd('FileType', {
    group = group,
    callback = function(args) remove_excluded_buf(args.buf) end,
  })

  api.nvim_create_autocmd('BufDelete', {
    group = group,
    callback = function(args) remove_buf_from_tabs(args.buf) end,
  })

  api.nvim_create_autocmd({ 'BufDelete', 'TabClosed' }, {
    group = group,
    callback = function(args) vim.schedule(args.event == 'BufDelete' and close_current_empty_buf or close_all_empty_bufs) end,
  })
end

setup_autocmds()

return M
