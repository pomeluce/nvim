local map = vim.keymap.set
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    PackUtils.load({ name = 'nvim-ufo', deps = { 'promise-async' } }, function()
      local fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local nline = endLnum - lnum
        local suffix = (' 󰛂  %d lines folded  '):format(nline)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth

        local newVirtText = {}
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkWidth = vim.fn.strdisplaywidth(chunk[1])
          if targetWidth > curWidth + chunkWidth then
            newVirtText[#newVirtText + 1] = chunk
          else
            chunk[1] = truncate(chunk[1], targetWidth - curWidth)
            newVirtText[#newVirtText + 1] = chunk
            break
          end
          curWidth = curWidth + chunkWidth
        end
        newVirtText[#newVirtText + 1] = { suffix, 'Comment' }
        return newVirtText
      end

      vim.opt.foldcolumn = '0'
      vim.opt.foldlevel = 20
      vim.opt.foldenable = true

      local ufo = require('ufo')
      ufo.setup({
        provider_selector = function() return { 'treesitter', 'indent' } end,
        fold_virt_text_handler = fold_virt_text_handler,
      })

      -- 外部进程(如 Claude Code CLI)修改文件并重载 buffer 后, ufo 折叠会失效。
      -- 根因: ufo 缓存 buffer 的 filetype(model/buffer.lua)且 reload() 不清缓存;
      -- treesitter provider 在 filetype 为空时 get_parser 失败会把 hasProviders[ft]
      -- 永久标记为 false(provider/treesitter.lua), 且 BufReload 不触发 fold 重算。
      -- 重载过程中 filetype 的瞬时中间态被缓存后, treesitter 折叠无法自动恢复。
      -- 重载完成后 detach+attach 重建 UfoBuffer 以重读 filetype。
      local function ufo_reattach(buf)
        if not vim.api.nvim_buf_is_valid(buf) then return end
        -- filetype 为空时从文件名重新检测(必须在 attach 前确保 ft 非空)
        if vim.bo[buf].filetype == '' then
          local ft = vim.filetype.match({ filename = vim.api.nvim_buf_get_name(buf) })
          if ft and ft ~= '' then vim.bo[buf].filetype = ft end
        end
        pcall(ufo.detach, buf)
        pcall(ufo.attach, buf)
      end
      vim.api.nvim_create_autocmd('BufReadPost', {
        group = vim.api.nvim_create_augroup('UfoReattach', { clear = true }),
        callback = function(args)
          -- 只对 ufo 已 attach 的 buffer 处理(重载场景), 避免首次打开的开销
          if ufo.hasAttached(args.buf) then vim.schedule(function() ufo_reattach(args.buf) end) end
        end,
      })

      -- 代码折叠
      map({ 'n', 'v' }, 'zz', 'za', { desc = 'Toggle fold current' })
      map('n', 'zM', ufo.closeAllFolds, { desc = 'Fold all' })
      map('n', 'zR', ufo.openAllFolds, { desc = 'Expand all' })
      map('n', 'zc', function() vim.cmd('silent! foldclose') end, { desc = 'Fold current' })
      map('n', 'zo', function() vim.cmd('silent! foldopen') end, { desc = 'Expand current' })
      map('n', '<leader>zz', function()
        local winid = vim.api.nvim_get_current_win()
        local has_open_fold = false

        vim.api.nvim_win_call(winid, function()
          local lnum = vim.fn.line('w0')
          local end_lnum = vim.fn.line('w$')

          while lnum <= end_lnum do
            local fc = vim.fn.foldclosed(lnum)
            if fc == -1 and vim.fn.foldlevel(lnum) > 0 then
              has_open_fold = true
              break
            end
            lnum = lnum + 1
          end
        end)

        if has_open_fold then
          ufo.closeAllFolds()
        else
          ufo.openAllFolds()
        end
      end, { desc = 'Toggle fold all' })
    end)
  end,
})
