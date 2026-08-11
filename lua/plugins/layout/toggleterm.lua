vim.api.nvim_create_autocmd('UIEnter', {
  group = vim.api.nvim_create_augroup('SetupToggleTerm', { clear = true }),
  once = true,
  callback = function()
    PackUtils.load({ name = 'toggleterm.nvim' }, function()
      local opts = {
        direction = 'float',
        highlights = { FloatBorder = { link = 'FloatBorder' } },
        float_opts = { width = 100, height = 30, title_pos = 'center', border = 'rounded' },
      }
      if require('utils').platform.is_win then opts.shell = 'pwsh.exe -NoLogo -NoProfile' end

      require('toggleterm').setup(opts)

      local term = require('configs.terminal')
      local map = vim.keymap.set

      -- tab 栏高亮: 仅文字颜色, 无背景
      local p = require('base16-colorscheme').colors
      vim.api.nvim_set_hl(0, 'TermTabActive', { fg = p.base0E, bold = true })
      vim.api.nvim_set_hl(0, 'TermTab', { fg = p.base04 })
      vim.api.nvim_set_hl(0, 'TermTabSep', { fg = p.base02 })

      -- 隐藏时打开终端; 可见时作为一次性前导键读取一个 tab 操作。
      map({ 'n', 't' }, '<C-t>', term.toggle_or_prefix, { desc = 'Terminal toggle/prefix' })

      local function is_mapped(lhs)
        for _, mode in ipairs({ 'n', 't' }) do
          if not vim.tbl_isempty(vim.fn.maparg(lhs, mode, false, true)) then return true end
        end
        return false
      end

      local codex_key
      for _, lhs in ipairs({ '<C-o>', '<leader>ao', '<leader>co' }) do
        if not is_mapped(lhs) then
          codex_key = lhs
          break
        end
      end
      if codex_key then
        map({ 'n', 't' }, codex_key, term.toggle_codex, { desc = 'Toggle Codex terminal' })
        if codex_key ~= '<C-o>' then vim.notify('<C-o> 已有映射，Codex 终端改用 ' .. codex_key, vim.log.levels.INFO, { title = 'Terminal' }) end
      else
        vim.notify('未找到可用的 Codex 终端快捷键，请使用 :CodexResume', vim.log.levels.WARN, { title = 'Terminal' })
      end

      -- 覆盖插件自带 :TermNew, 纳入 tab 系统(:ToggleTerm 保持原义)
      vim.api.nvim_create_user_command('TermNew', function() term.new_tab() end, { nargs = 0, desc = 'New terminal tab' })
      vim.api.nvim_create_user_command('TermRename', function(o) term.rename_tab(o.args) end, { nargs = '*', desc = 'Rename current terminal tab' })
      vim.api.nvim_create_user_command('TermSelect', function() term.select_tab() end, { nargs = 0, desc = 'Select terminal tab' })
      vim.api.nvim_create_user_command('CodexResume', function() term.toggle_codex() end, { nargs = 0, desc = 'Toggle Codex resume terminal' })

      map('n', '<leader>rf', term.runFile, { desc = 'Run current buffer file' })
      map('i', '<leader>rf', term.runFile, { desc = 'Run current buffer file' })
    end)
  end,
})
