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

      -- ufo 会在整个 buffer 重载时清空折叠; 同步重算以免快捷键撞上异步更新窗口.
      local folds_pending = {}
      local function recompute_folds(buf)
        if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then return false end
        if not ufo.hasAttached(buf) then ufo.attach(buf) end
        if not ufo.hasAttached(buf) then return false end

        local ok, ranges = pcall(ufo.getFolds, buf, 'treesitter')
        if not ok then
          ok, ranges = pcall(ufo.getFolds, buf, 'indent')
        end
        if ok and type(ranges) == 'table' and ufo.applyFolds(buf, ranges) ~= -1 then return true end

        -- 没有可用窗口或不在 Normal mode 时, 交给 ufo 在下一个安全时机更新.
        ufo.enableFold(buf)
        return false
      end
      local function ensure_folds_ready()
        local buf = vim.api.nvim_get_current_buf()
        if folds_pending[buf] and recompute_folds(buf) then folds_pending[buf] = nil end
      end
      vim.api.nvim_create_autocmd({ 'BufReadPost', 'FileChangedShellPost' }, {
        desc = 'Recompute ufo folds after buffer reload',
        group = vim.api.nvim_create_augroup('UfoReload', { clear = true }),
        callback = function(args)
          local buf = args.buf
          if vim.bo[buf].buftype ~= '' or not vim.b[buf].skip_fold_view then return end
          folds_pending[buf] = true
          vim.schedule(function()
            if folds_pending[buf] and recompute_folds(buf) then folds_pending[buf] = nil end
          end)
        end,
      })

      -- 代码折叠
      map({ 'n', 'v' }, 'zz', function()
        ensure_folds_ready()
        vim.cmd('silent! normal! za')
      end, { desc = 'Toggle fold current' })
      map('n', 'zM', function()
        ensure_folds_ready()
        ufo.closeAllFolds()
      end, { desc = 'Fold all' })
      map('n', 'zR', function()
        ensure_folds_ready()
        ufo.openAllFolds()
      end, { desc = 'Expand all' })
      map('n', 'zc', function()
        ensure_folds_ready()
        vim.cmd('silent! foldclose')
      end, { desc = 'Fold current' })
      map('n', 'zo', function()
        ensure_folds_ready()
        vim.cmd('silent! foldopen')
      end, { desc = 'Expand current' })
      map('n', '<leader>zz', function()
        ensure_folds_ready()
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
