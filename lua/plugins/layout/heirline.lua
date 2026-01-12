vim.pack.add({
  { src = 'https://github.com/rebelot/heirline.nvim' },
})

vim.t.bufs = vim.t.bufs or vim.tbl_filter(function(buf) return vim.fn.buflisted(buf) == 1 end, vim.api.nvim_list_bufs())

local api = vim.api
local map = vim.keymap.set
local cur_buf = api.nvim_get_current_buf
local set_buf = api.nvim_set_current_buf

local function buf_index(bufnr)
  for i, value in ipairs(vim.t.bufs) do
    if value == bufnr then return i end
  end
end
local function confirm_delete_buffer(bufnr)
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

local function close_buffer(bufnr)
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

    if not (bufhidden == 'delete') then confirm_delete_buffer(bufnr) end
  end

  vim.cmd('redrawtabline')
end
--- @param include_cur_buf boolean 是否关闭当前 buffer
local function close_all_buffer(include_cur_buf)
  local bufs = vim.t.bufs
  if include_cur_buf ~= nil and not include_cur_buf then table.remove(bufs, buf_index(cur_buf())) end
  for _, buf in ipairs(bufs) do
    close_buffer(buf)
  end
end

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  group = vim.api.nvim_create_augroup('SetupHeirline', { clear = true }),
  once = true,
  callback = function()
    require('heirline').setup({
      statusline = require('configs.statusline'),
      tabline = require('configs.tabline'),
    })
    vim.o.showtabline = 2
    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        if vim.bo.bufhidden == 'wipe' or vim.bo.bufhidden == 'delete' then vim.bo.buflisted = false end
      end,
    })

    -- 切换下一个 buf
    local function next_buf()
      local bufs = vim.t.bufs
      local curbufIndex = buf_index(cur_buf())
      if not curbufIndex then
        set_buf(vim.t.bufs[1])
        return
      end
      set_buf((curbufIndex == #bufs and bufs[1]) or bufs[curbufIndex + 1])
    end
    map('n', '<tab>', next_buf, { desc = 'Toggle to next buffer' })
    -- 切换上一个 buf
    local function prev_buf()
      local bufs = vim.t.bufs
      local curbufIndex = buf_index(cur_buf())
      if not curbufIndex then
        set_buf(vim.t.bufs[1])
        return
      end
      set_buf((curbufIndex == 1 and bufs[#bufs]) or bufs[curbufIndex - 1])
    end
    map('n', '<s-tab>', prev_buf, { desc = 'Toggle to prev buffer' })
    -- 删除当前 buffer
    map('n', '<leader>bc', close_buffer, { desc = 'Delete current buffer' })
    -- 删除所有 buffer
    map('n', '<leader>bC', function() close_all_buffer(false) end, { desc = 'Delete other buffers' })
  end,
})

-- autocmds for tabufline -> store bufnrs on bufadd, bufenter events
-- thx to https://github.com/ii14 & stores buffer per tab -> table
vim.api.nvim_create_autocmd({ 'BufAdd', 'BufEnter', 'TabNew' }, {
  group = vim.api.nvim_create_augroup('SetTabufs', { clear = true }),
  callback = function(args)
    local bufs = vim.t.bufs
    local is_curbuf = vim.api.nvim_get_current_buf() == args.buf

    if bufs == nil then
      bufs = vim.api.nvim_get_current_buf() == args.buf and {} or { args.buf }
    else
      -- check for duplicates
      if
        not vim.tbl_contains(bufs, args.buf)
        and (args.event == 'BufEnter' or not is_curbuf or vim.api.nvim_get_option_value('buflisted', { buf = args.buf }))
        and vim.api.nvim_buf_is_valid(args.buf)
        and vim.api.nvim_get_option_value('buflisted', { buf = args.buf })
      then
        table.insert(bufs, args.buf)
      end
    end

    -- remove unnamed buffer which isnt current buf & modified
    if args.event == 'BufAdd' then
      if #vim.api.nvim_buf_get_name(bufs[1]) == 0 and not vim.api.nvim_get_option_value('modified', { buf = bufs[1] }) then table.remove(bufs, 1) end
    end

    vim.t.bufs = bufs
  end,
})
vim.api.nvim_create_autocmd('BufDelete', {
  group = vim.api.nvim_create_augroup('DelTabuf', { clear = true }),
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
