local M = {}

local api = vim.api

--- 获取当前 tab 的 buffer 列表
local function get_tab_bufs() return vim.t.bufs or {} end

--- 设置当前 tab 的 buffer 列表
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
  ['checkhealth'] = true,
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
  if excluded_buftypes[buftype] then return false end

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

--- 清理 vim.t.bufs 中无效的 buffer
local function clean_invalid_bufs()
  local bufs = get_tab_bufs()
  local cleaned = {}
  for _, bufnr in ipairs(bufs) do
    if vim.api.nvim_buf_is_valid(bufnr) then table.insert(cleaned, bufnr) end
  end
  set_tab_bufs(cleaned)
  return cleaned
end

--- 获取 buffer 在 vim.t.bufs 中的索引
--- @param bufnr number
--- @return number|nil
local function buf_index(bufnr)
  if not bufnr then return nil end
  local bufs = get_tab_bufs()
  for i, value in ipairs(bufs) do
    if value == bufnr then return i end
  end
  return nil
end

--- 初始化当前 tab 的 buffer 列表
local function init_tab_bufs()
  if not vim.t.bufs then vim.t.bufs = vim.tbl_filter(function(buf) return vim.api.nvim_buf_is_valid(buf) and vim.fn.buflisted(buf) == 1 end, api.nvim_list_bufs()) end
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

--- 切换到下一个 buffer
function M.next_buf()
  local bufs = clean_invalid_bufs()
  if #bufs == 0 then return end

  local curbuf = cur_buf()
  local curbufIndex = buf_index(curbuf)

  -- 如果当前 buffer 不在列表中或无效, 切换到第一个有效 buffer
  if not curbufIndex then
    for _, bufnr in ipairs(bufs) do
      if safe_set_buf(bufnr) then return end
    end
    return
  end

  -- 查找下一个有效 buffer
  for i = 1, #bufs do
    local nextIndex = (curbufIndex + i - 1) % #bufs + 1
    if nextIndex ~= curbufIndex then
      local nextBuf = bufs[nextIndex]
      if safe_set_buf(nextBuf) then return end
    end
  end
end

--- 切换到上一个 buffer
function M.prev_buf()
  local bufs = clean_invalid_bufs()
  if #bufs == 0 then return end

  local curbuf = cur_buf()
  local curbufIndex = buf_index(curbuf)

  -- 如果当前 buffer 不在列表中或无效, 切换到第一个有效 buffer
  if not curbufIndex then
    for _, bufnr in ipairs(bufs) do
      if safe_set_buf(bufnr) then return end
    end
    return
  end

  -- 查找上一个有效 buffer
  for i = 1, #bufs do
    local prevIndex = ((curbufIndex - i - 1) % #bufs + #bufs) % #bufs + 1
    if prevIndex ~= curbufIndex then
      local prevBuf = bufs[prevIndex]
      if safe_set_buf(prevBuf) then return end
    end
  end
end

--- 关闭 buffer
--- @param bufnr number|nil buffer number, nil 则关闭当前 buffer
function M.close_buf(bufnr)
  bufnr = bufnr or cur_buf()

  if not vim.api.nvim_buf_is_valid(bufnr) then return end

  -- 如果是当前 tab 的最后一个 buffer 且有多个 tab, 先切换到其他 tab 再关闭
  if #vim.api.nvim_list_tabpages() > 1 then
    local bufs = get_tab_bufs()
    local is_last_buf = #bufs <= 2
    if is_last_buf then
      local cur_tab = vim.api.nvim_get_current_tabpage()
      local target_tab = nil
      for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        if tab ~= cur_tab then target_tab = tab end
      end
      vim.cmd('tabnext ' .. target_tab)
      if vim.api.nvim_tabpage_is_valid(cur_tab) then buf_del(bufnr) end
      vim.cmd('redrawtabline')
    end
    return
  end

  if vim.bo[bufnr].buftype == 'terminal' then
    vim.cmd(vim.bo[bufnr].buflisted and 'set nobl | enew' or 'hide')
  else
    local curBufIndex = buf_index(bufnr)
    local bufhidden = vim.bo[bufnr].bufhidden
    -- force close floating wins or nonbuflisted
    local win_config = api.nvim_win_get_config(0)
    if win_config.zindex then
      vim.cmd('bw')
      return
      -- handle listed bufs
    elseif curBufIndex and #vim.t.bufs > 1 then
      -- 先清理无效 buffer
      clean_invalid_bufs()

      -- 查找下一个有效的 buffer 来切换
      local targetBuf = nil
      for i = 1, #vim.t.bufs do
        local idx = ((curBufIndex - i - 1) % #vim.t.bufs + #vim.t.bufs) % #vim.t.bufs + 1
        if idx ~= curBufIndex then
          local buf = vim.t.bufs[idx]
          if vim.api.nvim_buf_is_valid(buf) then
            targetBuf = buf
            break
          end
        end
      end

      if targetBuf then
        -- 使用安全的方式切换 buffer
        if not safe_set_buf(targetBuf) then vim.cmd('enew') end
      else
        vim.cmd('enew')
      end
      -- handle unlisted
    elseif not vim.bo[bufnr].buflisted then
      local tmpbufnr = vim.t.bufs[#vim.t.bufs]
      if tmpbufnr and vim.api.nvim_buf_is_valid(tmpbufnr) then
        local winid = vim.fn.bufwinid(tmpbufnr)
        winid = winid ~= -1 and winid or 0
        api.nvim_set_current_win(winid)
        safe_set_buf(tmpbufnr)
      end
      vim.cmd('bw' .. bufnr)
      return
    else
      vim.cmd('enew')
    end

    if not (bufhidden == 'delete') then buf_del(bufnr) end
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
  if not vim.api.nvim_buf_is_valid(buf) then return false end

  local name = vim.api.nvim_buf_get_name(buf)
  if name ~= '' then return false end
  if vim.api.nvim_get_option_value('modified', { buf = buf }) then return false end
  local allowed_buftypes = { [''] = true, ['nofile'] = true }
  local allowed_filetypes = { [''] = true }
  local buftype = vim.api.nvim_get_option_value('buftype', { buf = buf }) or ''
  local filetype = vim.api.nvim_get_option_value('filetype', { buf = buf }) or ''
  if not allowed_buftypes[buftype] then return false end
  if not allowed_filetypes[filetype] then return false end

  return true
end

-- 初始化 autocmds
if not vim.b.tabuf_load then
  vim.b.tabuf_load = true

  --- 监听 BufAdd, BufEnter, TabNew 事件来维护 buffer 列表
  vim.api.nvim_create_autocmd({ 'BufAdd', 'BufEnter', 'TabNew' }, {
    group = vim.api.nvim_create_augroup('SetTabufs', { clear = true }),
    callback = function(args)
      -- 确保 buffer 有效
      if not vim.api.nvim_buf_is_valid(args.buf) then return end

      local bufs = get_tab_bufs()
      local is_curbuf = cur_buf() == args.buf

      -- 如果 buffer 不在列表中, 根据事件类型决定是否添加
      if not vim.tbl_contains(bufs, args.buf) then
        local should_add = false
        if args.event == 'BufEnter' then
          should_add = should_include_buf(args.buf)
        elseif args.event == 'BufAdd' then
          should_add = should_include_buf(args.buf)
        elseif args.event == 'TabNew' then
          should_add = is_curbuf and should_include_buf(args.buf)
        end

        if should_add then table.insert(bufs, args.buf) end
      end

      -- 处理 BufAdd 事件: 如果第一个 buffer 是空 buffer, 移除它
      if args.event == 'BufAdd' and #bufs > 0 then
        local first_buf = bufs[1]
        if vim.api.nvim_buf_is_valid(first_buf) then
          local first_name = vim.api.nvim_buf_get_name(first_buf)
          local first_modified = vim.api.nvim_get_option_value('modified', { buf = first_buf })
          if #first_name == 0 and not first_modified then table.remove(bufs, 1) end
        end
      end

      set_tab_bufs(bufs)
    end,
  })

  --- 监听 BufDelete 事件来从所有 tab 的 buffer 列表中删除此 buffer
  vim.api.nvim_create_autocmd('BufDelete', {
    group = vim.api.nvim_create_augroup('UpTabufs', { clear = true }),
    callback = function(args)
      -- 从所有 tab 的 buffer 列表中删除此 buffer
      for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local tab_bufs = vim.t[tab].bufs
        if tab_bufs then
          for i = #tab_bufs, 1, -1 do
            if tab_bufs[i] == args.buf then table.remove(tab_bufs, i) end
          end
          vim.t[tab].bufs = tab_bufs
        end
      end
      -- 同时更新当前 tab 的 bufs
      if vim.t.bufs then
        for i = #vim.t.bufs, 1, -1 do
          if vim.t.bufs[i] == args.buf then table.remove(vim.t.bufs, i) end
        end
      end
    end,
  })

  --- 监听 BufDelete 和 TabClosed 事件来清理空 buffer
  vim.api.nvim_create_autocmd({ 'BufDelete', 'TabClosed' }, {
    group = vim.api.nvim_create_augroup('CloseEmpytBuf', { clear = true }),
    callback = function(args)
      -- tab > 1: delete last buffer, close empty tab
      local function _del_empty_bf_close()
        local tab = vim.api.nvim_get_current_tabpage()
        local wins = vim.api.nvim_tabpage_list_wins(tab)
        if #wins ~= 1 then return end
        local buf = vim.api.nvim_win_get_buf(wins[1])
        if M.empty_buf(buf) then M.close_buf(buf) end
      end
      -- tab close: delete empty buf
      local function _del_empty_tb_close()
        local bufs = vim.api.nvim_list_bufs()
        for _, buf in ipairs(bufs) do
          if M.empty_buf(buf) then M.close_buf(buf) end
        end
      end
      vim.schedule(args.event == 'BufDelete' and _del_empty_bf_close or _del_empty_tb_close)
    end,
  })
end

return M
