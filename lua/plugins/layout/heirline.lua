vim.api.nvim_create_autocmd('UIEnter', {
  once = true,
  callback = function()
    PackUtils.load({ name = 'heirline.nvim' }, function()
      local map = vim.keymap.set
      local tabuf = require('configs.tabufs')

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
      map('n', '<tab>', tabuf.next_buf, { desc = 'Toggle to next buffer' })
      map('n', '<s-tab>', tabuf.prev_buf, { desc = 'Toggle to prev buffer' })
      map('n', '<leader>bc', tabuf.close_buf, { desc = 'Delete current buffer' })
      map('n', '<leader>bC', function() tabuf.close_bufs(false) end, { desc = 'Delete other buffers' })
    end)
  end,
})
