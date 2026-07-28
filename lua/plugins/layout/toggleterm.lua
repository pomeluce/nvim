vim.api.nvim_create_autocmd('UIEnter', {
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
      vim.api.nvim_set_hl(0, 'TermTabMode', { fg = p.base08, bold = true })

      -- <C-t>: 浮动终端开关(常驻); <A-o>: 进入 tab 管理子模式(仅终端可见时绑定)
      map({ 'n', 't' }, '<C-t>', term.toggle_default, { desc = 'Toggle float terminal' })

      local saved_a_o
      local function bind_term_keys()
        saved_a_o = {
          n = term.get_global_map('n', '<A-o>'),
          t = term.get_global_map('t', '<A-o>'),
        }
        map({ 'n', 't' }, '<A-o>', term.enter_tabmode, { desc = 'Term: tab mode (n/w/l/h/r/1-9)' })
      end
      local function unbind_term_keys()
        term.restore_global_map('n', '<A-o>', saved_a_o and saved_a_o.n)
        term.restore_global_map('t', '<A-o>', saved_a_o and saved_a_o.t)
      end
      term.set_hooks(bind_term_keys, unbind_term_keys)

      -- 覆盖插件自带 :TermNew, 纳入 tab 系统(:ToggleTerm 保持原义)
      vim.api.nvim_create_user_command('TermNew', function() term.new_tab() end, { nargs = 0, desc = 'New terminal tab' })
      vim.api.nvim_create_user_command('TermRename', function(o) term.rename_tab(o.args) end, { nargs = '*', desc = 'Rename current terminal tab' })

      map('n', '<leader>rf', term.runFile, { desc = 'Run current buffer file' })
      map('i', '<leader>rf', term.runFile, { desc = 'Run current buffer file' })
    end)
  end,
})
