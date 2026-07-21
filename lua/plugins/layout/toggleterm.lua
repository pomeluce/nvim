vim.api.nvim_create_autocmd('UIEnter', {
  once = true,
  callback = function()
    PackUtils.load({ name = 'toggleterm.nvim' }, function()
      local opts = {
        direction = 'float',
        highlights = { FloatBorder = { link = 'FloatBorder' } },
        float_opts = { width = 100, height = 30, title_pos = 'center', border = 'rounded' },
      }
      if require('utils').is_win then opts.shell = 'pwsh.exe --noLog' end

      require('toggleterm').setup(opts)

      local term = require('configs.terminal')
      local map = vim.keymap.set

      -- tab 栏高亮: 仅文字颜色, 无背景
      local p = require('base16-colorscheme').colors
      vim.api.nvim_set_hl(0, 'TermTabActive', { fg = p.base0E, bold = true })
      vim.api.nvim_set_hl(0, 'TermTab', { fg = p.base04 })
      vim.api.nvim_set_hl(0, 'TermTabSep', { fg = p.base02 })

      -- 默认浮动终端: 开关 + 多 tab 管理(Alt 组合, n/t 模式)
      map({ 'n', 't' }, '<C-t>', term.toggle_default, { desc = 'Toggle float terminal' })
      map({ 'n', 't' }, '<A-n>', term.new_tab, { desc = 'Term: new tab' })
      map({ 'n', 't' }, '<A-w>', term.close_tab, { desc = 'Term: close tab' })
      map({ 'n', 't' }, '<A-l>', term.next_tab, { desc = 'Term: next tab' })
      map({ 'n', 't' }, '<A-h>', term.prev_tab, { desc = 'Term: prev tab' })
      map({ 'n', 't' }, '<A-r>', function() term.rename_tab() end, { desc = 'Term: rename tab' })
      for i = 1, 9 do
        map({ 'n', 't' }, string.format('<A-%d>', i), function() term.goto_tab(i) end, { desc = 'Term: goto tab ' .. i })
      end

      -- 覆盖插件自带 :TermNew, 纳入 tab 系统(:ToggleTerm 保持原义)
      vim.api.nvim_create_user_command('TermNew', function() term.new_tab() end, { nargs = '*', desc = 'New terminal tab' })
      vim.api.nvim_create_user_command('TermRename', function(o) term.rename_tab(o.args) end, { nargs = '*', desc = 'Rename current terminal tab' })

      map('n', '<leader>rf', term.runFile, { desc = 'Run current buffer file' })
      map('i', '<leader>rf', term.runFile, { desc = 'Run current buffer file' })
    end)
  end,
})
