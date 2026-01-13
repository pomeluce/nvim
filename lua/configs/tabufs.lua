local M = {}

vim.t.bufs = vim.t.bufs or vim.tbl_filter(function(buf) return vim.fn.buflisted(buf) == 1 end, vim.api.nvim_list_bufs())

local api = vim.api
local cur_buf = api.nvim_get_current_buf
local set_buf = api.nvim_set_current_buf

local function buf_index(bufnr)
  for i, value in ipairs(vim.t.bufs) do
    if value == bufnr then return i end
  end
end
local function buf_del(bufnr)
  local modified = vim.api.nvim_get_option_value('modified', { buf = bufnr })

  if modified then
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    bufname = bufname == '' and '[No Name]' or vim.fn.fnamemodify(bufname, ':~:.')
    if bufname:match('^/') then bufname = vim.fn.fnamemodify(bufname, ':t') end
    if bufname == '' then bufname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t') end
    local choice = vim.fn.confirm('Save changes to "' .. bufname .. '"?', '&Yes\n&No\n&Cancel', 1, 'Question')
    if choice == 1 then
      vim.api.nvim_buf_call(bufnr, function() vim.cmd('write') end)
      vim.api.nvim_buf_delete(bufnr, { force = false })
    else
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end
  else
    vim.api.nvim_buf_delete(bufnr, { force = false })
  end
end

function M.next_buf()
  local bufs = vim.t.bufs
  local curbufIndex = buf_index(cur_buf())
  if not curbufIndex then
    set_buf(vim.t.bufs[1])
    return
  end
  set_buf((curbufIndex == #bufs and bufs[1]) or bufs[curbufIndex + 1])
end

function M.prev_buf()
  local bufs = vim.t.bufs
  local curbufIndex = buf_index(cur_buf())
  if not curbufIndex then
    set_buf(vim.t.bufs[1])
    return
  end
  set_buf((curbufIndex == 1 and bufs[#bufs]) or bufs[curbufIndex - 1])
end

--- @param bufnr number|nil buffer number, nil 则关闭当前 buffer
function M.close_buf(bufnr)
  bufnr = bufnr or cur_buf()

  if vim.bo[bufnr].buftype == 'terminal' then
    vim.cmd(vim.bo.buflisted and 'set nobl | enew' or 'hide')
  else
    local curBufIndex = buf_index(bufnr)
    local bufhidden = vim.bo.bufhidden
    -- force close floating wins or nonbuflisted
    if api.nvim_win_get_config(0).zindex then
      vim.cmd('bw')
      return
      -- handle listed bufs
    elseif curBufIndex and #vim.t.bufs > 1 then
      local newBufIndex = curBufIndex == #vim.t.bufs and -1 or 1
      vim.cmd('b' .. vim.t.bufs[curBufIndex + newBufIndex])
      -- handle unlisted
    elseif not vim.bo.buflisted then
      local tmpbufnr = vim.t.bufs[1]
      if tmpbufnr then
        local winid = vim.fn.bufwinid(tmpbufnr)
        winid = winid ~= -1 and winid or 0
        api.nvim_set_current_win(winid)
        api.nvim_set_current_buf(tmpbufnr)
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

--- @param include_cur_buf boolean 是否关闭当前 buffer
function M.cloase_bufs(include_cur_buf)
  local bufs = vim.t.bufs
  if include_cur_buf ~= nil and not include_cur_buf then table.remove(bufs, buf_index(cur_buf())) end
  for _, buf in ipairs(bufs) do
    M.close_buf(buf)
  end
end

--- @param buf number buffer number
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

if not vim.b.tabuf_load then
  vim.b.tabuf_load = true
  -- autocmds for tabufline -> store bufnrs on bufadd, bufenter events
  -- thx to https://github.com/ii14 & stores buffer per tab -> table
  vim.api.nvim_create_autocmd({ 'BufAdd', 'BufEnter', 'TabNew' }, {
    group = vim.api.nvim_create_augroup('SetTabufs', { clear = true }),
    callback = function(args)
      local bufs = vim.t.bufs
      local is_curbuf = cur_buf() == args.buf
      if bufs == nil then
        bufs = cur_buf() == args.buf and {} or { args.buf }
      else
        if
          not vim.tbl_contains(bufs, args.buf)
          and (args.event == 'BufEnter' or not is_curbuf or vim.api.nvim_get_option_value('buflisted', { buf = args.buf }))
          and vim.api.nvim_buf_is_valid(args.buf)
          and vim.api.nvim_get_option_value('buflisted', { buf = args.buf })
        then
          table.insert(bufs, args.buf)
        end
      end
      if args.event == 'BufAdd' then
        if #vim.api.nvim_buf_get_name(bufs[1]) == 0 and not vim.api.nvim_get_option_value('modified', { buf = bufs[1] }) then table.remove(bufs, 1) end
      end
      vim.t.bufs = bufs
    end,
  })
  vim.api.nvim_create_autocmd('BufDelete', {
    group = vim.api.nvim_create_augroup('UpTabufs', { clear = true }),
    callback = function(args)
      for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local bufs = vim.t[tab].bufs
        if bufs then
          for i, bufnr in ipairs(bufs) do
            if bufnr == args.buf then
              table.remove(bufs, i)
              vim.t[tab].bufs = bufs
              break
            end
          end
        end
      end
    end,
  })
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
