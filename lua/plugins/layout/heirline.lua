vim.pack.add({
  { src = 'https://github.com/rebelot/heirline.nvim' },
})

local map = vim.keymap.set
local tabuf = require('configs.tabufs')

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
    map('n', '<tab>', tabuf.next_buf, { desc = 'Toggle to next buffer' })
    -- 切换上一个 buf
    map('n', '<s-tab>', tabuf.prev_buf, { desc = 'Toggle to prev buffer' })
    -- 删除当前 buffer
    map('n', '<leader>bc', tabuf.close_buf, { desc = 'Delete current buffer' })
    -- 删除所有 buffer
    map('n', '<leader>bC', function() tabuf.cloase_bufs(false) end, { desc = 'Delete other buffers' })
  end,
})
