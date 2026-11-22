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

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('DisableTerminalToggleInAgents', { clear = true }),
        pattern = { 'claudecode', 'codex-terminal' },
        callback = function(event) vim.keymap.set('t', '<C-t>', '<C-t>', { buffer = event.buf, remap = false, silent = true }) end,
      })

      -- 覆盖插件自带 :TermNew, 纳入 tab 系统(:ToggleTerm 保持原义)
      vim.api.nvim_create_user_command('TermNew', function() term.new_tab() end, { nargs = 0, desc = 'New terminal tab' })
      vim.api.nvim_create_user_command('TermRename', function(o) term.rename_tab(o.args) end, { nargs = '*', desc = 'Rename current terminal tab' })
      vim.api.nvim_create_user_command('TermSelect', function() term.select_tab() end, { nargs = 0, desc = 'Select terminal tab' })

      map('n', '<leader>rf', term.runFile, { desc = 'Run current buffer file' })
      map('i', '<leader>rf', term.runFile, { desc = 'Run current buffer file' })
    end)
  end,
})
