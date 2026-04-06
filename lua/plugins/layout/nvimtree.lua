vim.g.nvim_tree_firsttime = 1
vim.cmd('hi! NvimTreeCursorLine cterm=NONE ctermbg=238')
vim.cmd('hi! link NvimTreeFolderIcon NvimTreeFolderName')

---@type packman.SpecItem[]
return {
  {
    'nvim-tree/nvim-tree.lua',
    event = 'VimEnter',
    config = function()
      require('nvim-tree').setup({
        sort_by = 'case_sensitive',
        actions = { open_file = { window_picker = { enable = false } } },
        on_attach = function(bufnr)
          local map = vim.keymap.set
          local api = require('nvim-tree.api')
          local opts = function(desc) return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true } end
          api.config.mappings.default_on_attach(bufnr)
          map('n', '<Esc>', api.tree.close, opts('Close'))
          map('n', '<Tab>', api.node.open.edit, opts('Open'))
          map('n', '(', api.node.navigate.git.prev, opts('Prev Git'))
          map('n', ')', api.node.navigate.git.next, opts('Next Git'))
          map('n', '>', api.node.navigate.diagnostics.next, opts('Next Diagnostic'))
          map('n', '<', api.node.navigate.diagnostics.prev, opts('Prev Diagnostic'))
          map('n', 'n', api.node.navigate.sibling.next, opts('Next Sibling'))
          map('n', 'N', api.node.navigate.sibling.prev, opts('Previous Sibling'))
          map('n', '?', api.tree.toggle_help, opts('Help'))
        end,
        view = { width = 30, preserve_window_proportions = true },
        update_focused_file = { enable = true, update_root = false, ignore_list = {} },
        renderer = {
          root_folder_label = false,
          highlight_git = true,
          group_empty = true,
          indent_markers = { enable = true },
          icons = {
            git_placement = 'after',
            webdev_colors = true,
            glyphs = {
              default = '󰈚',
              folder = { default = '', empty = '', empty_open = '', open = '', symlink = '' },
              git = { unstaged = '~', staged = '✓', unmerged = '', renamed = '+', untracked = '?', deleted = '', ignored = ' ' },
            },
          },
        },
        filters = { dotfiles = false },
        diagnostics = { enable = true, show_on_dirs = true, debounce_delay = 50, icons = { hint = '', info = '', warning = '', error = '' } },
        disable_netrw = true,
        hijack_cursor = true,
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
      })
    end,
  },
}
