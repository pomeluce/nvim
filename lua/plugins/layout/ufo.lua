local map = vim.keymap.set

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
