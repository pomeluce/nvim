vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    PackUtils.load({ name = 'ts-comments.nvim' }, function()
      local map = vim.keymap.set
      local bc = require('configs.block_comment')
      require('ts-comments').setup({})

      -- 行注释(ts-comments 提供)
      map('n', '<leader>/', 'gcc', { remap = true, desc = 'Toggle line comment' })
      map('v', '<leader>/', 'gc', { remap = true, desc = 'Toggle line comment' })

      -- 块注释(BlockComment 模块)
      map('n', '<leader><leader>/', function()
        local line = vim.fn.line('.')
        local count = vim.v.count > 0 and vim.v.count or 1
        bc.toggle_block_comment(line, line + count - 1)
      end, { desc = 'Toggle block comment' })

      -- visual 模式用 expr 返回 keys 字符串, 避免在回调内操作 buffer
      map('x', '<leader><leader>/', function()
        local sl = vim.fn.line('v')
        local el = vim.fn.line('.')
        if sl > el then
          sl, el = el, sl
        end
        -- expr 返回的字符串由 Neovim 作为按键序列处理
        return '<Esc>:lua require("configs.block_comment").toggle_block_comment(' .. sl .. ',' .. el .. ')<CR>'
      end, { expr = true, desc = 'Toggle block comment' })
    end)
  end,
})
