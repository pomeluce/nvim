local M = {}

-- 快捷键配置
function M.on_attach(bufnr)
  local api = require('nvim-tree.api')
  -- BEGIN_DEFAULT_ON_ATTACH
  local opts = function(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end
  local map = require('user.core.mappings').map

  -- 默认配置
  map('n', '<C-]>', api.tree.change_root_to_node, opts('CD'))
  map('n', '<C-e>', api.node.open.replace_tree_buffer, opts('Open: In Place'))
  map('n', '<C-k>', api.node.show_info_popup, opts('Info'))
  map('n', '<C-r>', api.fs.rename_sub, opts('Rename: Omit Filename'))
  map('n', '<C-t>', api.node.open.tab, opts('Open: New Tab'))
  map('n', '<C-v>', api.node.open.vertical, opts('Open: Vertical Split'))
  map('n', '<C-x>', api.node.open.horizontal, opts('Open: Horizontal Split'))
  map('n', '<BS>', api.node.navigate.parent_close, opts('Close Directory'))
  map('n', '<CR>', api.node.open.edit, opts('Open'))
  map('n', '<Tab>', api.node.open.preview, opts('Open Preview'))
  map('n', '>', api.node.navigate.sibling.next, opts('Next Sibling'))
  map('n', '<', api.node.navigate.sibling.prev, opts('Previous Sibling'))
  map('n', '.', api.node.run.cmd, opts('Run Command'))
  map('n', '-', api.tree.change_root_to_parent, opts('Up'))
  map('n', 'a', api.fs.create, opts('Create'))
  map('n', 'bmv', api.marks.bulk.move, opts('Move Bookmarked'))
  map('n', 'B', api.tree.toggle_no_buffer_filter, opts('Toggle No Buffer'))
  map('n', 'c', api.fs.copy.node, opts('Copy'))
  map('n', 'C', api.tree.toggle_git_clean_filter, opts('Toggle Git Clean'))
  map('n', '[c', api.node.navigate.git.prev, opts('Prev Git'))
  map('n', ']c', api.node.navigate.git.next, opts('Next Git'))
  map('n', 'd', api.fs.remove, opts('Delete'))
  map('n', 'D', api.fs.trash, opts('Trash'))
  map('n', 'E', api.tree.expand_all, opts('Expand All'))
  map('n', 'e', api.fs.rename_basename, opts('Rename: Basename'))
  map('n', ']e', api.node.navigate.diagnostics.next, opts('Next Diagnostic'))
  map('n', '[e', api.node.navigate.diagnostics.prev, opts('Prev Diagnostic'))
  map('n', 'F', api.live_filter.clear, opts('Clean Filter'))
  map('n', 'f', api.live_filter.start, opts('Filter'))
  map('n', 'g?', api.tree.toggle_help, opts('Help'))
  map('n', 'gy', api.fs.copy.absolute_path, opts('Copy Absolute Path'))
  map('n', 'H', api.tree.toggle_hidden_filter, opts('Toggle Dotfiles'))
  map('n', 'I', api.tree.toggle_gitignore_filter, opts('Toggle Git Ignore'))
  map('n', 'J', api.node.navigate.sibling.last, opts('Last Sibling'))
  map('n', 'K', api.node.navigate.sibling.first, opts('First Sibling'))
  map('n', 'm', api.marks.toggle, opts('Toggle Bookmark'))
  map('n', 'o', api.node.open.edit, opts('Open'))
  map('n', 'O', api.node.open.no_window_picker, opts('Open: No Window Picker'))
  map('n', 'p', api.fs.paste, opts('Paste'))
  map('n', 'P', api.node.navigate.parent, opts('Parent Directory'))
  map('n', 'q', api.tree.close, opts('Close'))
  map('n', 'r', api.fs.rename, opts('Rename'))
  map('n', 'R', api.tree.reload, opts('Refresh'))
  map('n', 's', api.node.run.system, opts('Run System'))
  map('n', 'S', api.tree.search_node, opts('Search'))
  map('n', 'U', api.tree.toggle_custom_filter, opts('Toggle Hidden'))
  map('n', 'W', api.tree.collapse_all, opts('Collapse'))
  map('n', 'x', api.fs.cut, opts('Cut'))
  map('n', 'y', api.fs.copy.filename, opts('Copy Name'))
  map('n', 'Y', api.fs.copy.relative_path, opts('Copy Relative Path'))
  map('n', '<2-LeftMouse>', api.node.open.edit, opts('Open'))
  map('n', '<2-RightMouse>', api.tree.change_root_to_node, opts('CD'))

  --[[  自定义配置 ]]
  -- 进入目录
  map('n', '<CR>', api.tree.change_root_to_node, opts('CD'))
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
end

function M.config()
  vim.g.nvim_tree_firsttime = 1
  vim.cmd('hi! NvimTreeCursorLine cterm=NONE ctermbg=238')
  vim.cmd('hi! link NvimTreeFolderIcon NvimTreeFolderName')
  -- vim.cmd("au FileType NvimTree nnoremap <buffer> <silent> C :lua require('user.configs.nvim-tree').magicCd()<cr>")
end

function M.setup()
  dofile(vim.g.base46_cache .. 'nvimtree')

  return {
    sort_by = 'case_sensitive',
    -- 在多个窗口下打开 buffer 时, 默认使用最近窗口
    actions = {
      open_file = {
        window_picker = { enable = false },
      },
    },
    on_attach = M.on_attach,
    view = {
      width = 30,
      preserve_window_proportions = true,
      -- 浮动设置
      -- float = {
      --   enable = true,
      --   open_win_config = function()
      --     local columns = vim.o.columns
      --     local lines = vim.o.lines
      --     local width = math.max(math.floor(lines * 0.36), 30)
      --     local height = math.max(math.floor(lines * 0.6), 20)
      --     local left = math.ceil((columns - width) * 1)
      --     local top = math.ceil((lines - height) * 0.1 - 2)
      --     return { relative = 'editor', border = 'rounded', width = width, height = height, row = top, col = left }
      --   end,
      -- },
    },
    update_focused_file = {
      enable = true,
      update_root = false,
      ignore_list = {},
    },
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
          folder = {
            default = '',
            empty = '',
            empty_open = '',
            open = '',
            symlink = '',
          },
          git = {
            unstaged = '~',
            staged = '✓',
            unmerged = '',
            renamed = '+',
            untracked = '?',
            deleted = '',
            ignored = ' ',
          },
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
end

return M
