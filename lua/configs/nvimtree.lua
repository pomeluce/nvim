dofile(vim.g.base46_cache .. 'nvimtree')

return {
  sort_by = 'case_sensitive',
  -- 在多个窗口下打开 buffer 时, 默认使用最近窗口
  actions = { open_file = { window_picker = { enable = false } } },
  on_attach = function(bufnr)
    require('core.mappings').nvim_tree(bufnr)
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
  diagnostics = {
    enable = true,
    show_on_dirs = true,
    debounce_delay = 50,
    icons = { hint = '', info = '', warning = '', error = '' },
  },
  disable_netrw = true,
  hijack_cursor = true,
  sync_root_with_cwd = true,
  respect_buf_cwd = true,
}
