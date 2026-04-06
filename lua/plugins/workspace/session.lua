vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

---@type packman.SpecItem[]
return {
  {
    'coffebar/neovim-project',
    dependencies = { 'Shatur/neovim-session-manager', 'nvim-lua/plenary.nvim' },
    config = function()
      require('neovim-project').setup({
        projects = require('utils').settings('session.projects'),
        datapath = vim.fn.stdpath('data'),
        last_session_on_startup = false,
        dashboard_mode = false,
        filetype_autocmd_timeout = 200,
        session_manager_opts = {
          autosave_ignore_filetypes = { 'gitcommit', 'gitrebase' },
          autosave_ignore_dirs = vim.list_extend({ vim.fn.expand('~'), '/' }, require('utils').settings('session.ignore_dir')),
        },
        picker = {
          type = 'snacks',
          preview = { enabled = true, git_status = true, git_fetch = false, show_hidden = true },
          opts = { layout = 'dropdown' },
        },
      })
    end,
  },
}
