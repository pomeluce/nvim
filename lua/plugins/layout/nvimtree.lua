vim.pack.add({
  { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
})

vim.g.nvim_tree_firsttime = 1
vim.cmd('hi! NvimTreeCursorLine cterm=NONE ctermbg=238')
vim.cmd('hi! link NvimTreeFolderIcon NvimTreeFolderName')

require('nvim-tree').setup({
  sort_by = 'case_sensitive',
  -- 在多个窗口下打开 buffer 时, 默认使用最近窗口
  actions = { open_file = { window_picker = { enable = false } } },
  on_attach = function(bufnr)
    local map = require('utils').map
    local api = require('nvim-tree.api')
    -- BEGIN_DEFAULT_ON_ATTACH
    local opts = function(desc) return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true } end
    -- 默认配置
    api.config.mappings.default_on_attach(bufnr)
    -- 关闭目录
    map('n', '<Esc>', api.tree.close, opts('Close'))
    -- 展开目录
    map('n', '<Tab>', api.node.open.edit, opts('Open'))
    -- 上一个 git 文件
    map('n', '(', api.node.navigate.git.prev, opts('Prev Git'))
    -- 下一个 git 文件
    map('n', ')', api.node.navigate.git.next, opts('Next Git'))
    -- 下一个 dialog 文件
    map('n', '>', api.node.navigate.diagnostics.next, opts('Next Diagnostic'))
    -- 上一个 dialog 文件
    map('n', '<', api.node.navigate.diagnostics.prev, opts('Prev Diagnostic'))
    -- 下一个兄弟文件
    map('n', 'n', api.node.navigate.sibling.next, opts('Next Sibling'))
    -- 上一个兄弟文件
    map('n', 'N', api.node.navigate.sibling.prev, opts('Previous Sibling'))
    -- 帮助手册
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
