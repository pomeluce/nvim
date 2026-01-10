vim.pack.add({
  { src = 'https://github.com/rebelot/heirline.nvim' },
})

local api = vim.api
local cur_buf = api.nvim_get_current_buf
local set_buf = api.nvim_set_current_buf

local function buf_index(bufnr)
  for i, value in ipairs(vim.t.bufs) do
    if value == bufnr then return i end
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

    local map = require('utils').map

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

        if not (bufhidden == 'delete') then vim.cmd('confirm bd' .. bufnr) end
      end

      vim.cmd('redrawtabline')
    end
    map('n', '<leader>bc', close_buffer, { desc = 'Delete current buffer' })

    -- 删除所有 buffer
    --- @param include_cur_buf boolean 是否关闭当前 buffer
    local function close_all_buffer(include_cur_buf)
      local bufs = vim.t.bufs
      if include_cur_buf ~= nil and not include_cur_buf then table.remove(bufs, buf_index(cur_buf())) end
      for _, buf in ipairs(bufs) do
        close_buffer(buf)
      end
    end
    map('n', '<leader>bC', function() close_all_buffer(false) end, { desc = 'Delete other buffers' })
  end,
})
