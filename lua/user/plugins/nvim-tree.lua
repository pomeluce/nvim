local M = {}

-- 有时候进入到依赖文件内，此时想在依赖文件所在目录查看文件 nvim-tree 并没有一个很好的方法，所以写了这个func
local inner_cwd = ''
local outer_cwd = ''
function M.magicCd()
  local api = require('nvim-tree.api')
  local core = require('nvim-tree.core')

  local file_path = vim.fn.expand('#:p:h')
  local tree_cwd = core.get_cwd()

  if inner_cwd == '' then
    inner_cwd = tree_cwd
  end

  -- 树在内部目录 且 当前文件为外部文件 则切换到外部目录
  if tree_cwd == inner_cwd and string.find(file_path, '^' .. inner_cwd) == nil then
    inner_cwd = tree_cwd
    outer_cwd = file_path
    return api.tree.change_root(file_path)
  end

  -- 树在内部目录 且 当前文件为内部文件 则切换到外部目录（如果有的话）
  if tree_cwd == inner_cwd and string.find(file_path, '^' .. inner_cwd) ~= nil then
    if outer_cwd ~= '' then
      return api.tree.change_root(outer_cwd)
    end
  end

  -- 树在外部目录 且 当前文件为外部文件 则切换到内部目录
  if tree_cwd ~= inner_cwd and string.find(file_path, '^' .. outer_cwd) ~= nil then
    return api.tree.change_root(inner_cwd)
  end

  -- 树在外部目录 且 当前文件为内部文件 则切换到内部目录
  if tree_cwd ~= inner_cwd and string.find(file_path, '^' .. inner_cwd) ~= nil then
    return api.tree.change_root(inner_cwd)
  end
end

-- 快捷键配置
function M.on_attach(bufnr)
  local api = require('nvim-tree.api')
  -- BEGIN_DEFAULT_ON_ATTACH
  local opts = function(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end
  local keymap = vim.keymap.set

  -- 默认配置
  keymap('n', '<C-]>', api.tree.change_root_to_node, opts('CD'))
  keymap('n', '<C-e>', api.node.open.replace_tree_buffer, opts('Open: In Place'))
  keymap('n', '<C-k>', api.node.show_info_popup, opts('Info'))
  keymap('n', '<C-r>', api.fs.rename_sub, opts('Rename: Omit Filename'))
  keymap('n', '<C-t>', api.node.open.tab, opts('Open: New Tab'))
  keymap('n', '<C-v>', api.node.open.vertical, opts('Open: Vertical Split'))
  keymap('n', '<C-x>', api.node.open.horizontal, opts('Open: Horizontal Split'))
  keymap('n', '<BS>', api.node.navigate.parent_close, opts('Close Directory'))
  keymap('n', '<CR>', api.node.open.edit, opts('Open'))
  keymap('n', '<Tab>', api.node.open.preview, opts('Open Preview'))
  keymap('n', '>', api.node.navigate.sibling.next, opts('Next Sibling'))
  keymap('n', '<', api.node.navigate.sibling.prev, opts('Previous Sibling'))
  keymap('n', '.', api.node.run.cmd, opts('Run Command'))
  keymap('n', '-', api.tree.change_root_to_parent, opts('Up'))
  keymap('n', 'a', api.fs.create, opts('Create'))
  keymap('n', 'bmv', api.marks.bulk.move, opts('Move Bookmarked'))
  keymap('n', 'B', api.tree.toggle_no_buffer_filter, opts('Toggle No Buffer'))
  keymap('n', 'c', api.fs.copy.node, opts('Copy'))
  keymap('n', 'C', api.tree.toggle_git_clean_filter, opts('Toggle Git Clean'))
  keymap('n', '[c', api.node.navigate.git.prev, opts('Prev Git'))
  keymap('n', ']c', api.node.navigate.git.next, opts('Next Git'))
  keymap('n', 'd', api.fs.remove, opts('Delete'))
  keymap('n', 'D', api.fs.trash, opts('Trash'))
  keymap('n', 'E', api.tree.expand_all, opts('Expand All'))
  keymap('n', 'e', api.fs.rename_basename, opts('Rename: Basename'))
  keymap('n', ']e', api.node.navigate.diagnostics.next, opts('Next Diagnostic'))
  keymap('n', '[e', api.node.navigate.diagnostics.prev, opts('Prev Diagnostic'))
  keymap('n', 'F', api.live_filter.clear, opts('Clean Filter'))
  keymap('n', 'f', api.live_filter.start, opts('Filter'))
  keymap('n', 'g?', api.tree.toggle_help, opts('Help'))
  keymap('n', 'gy', api.fs.copy.absolute_path, opts('Copy Absolute Path'))
  keymap('n', 'H', api.tree.toggle_hidden_filter, opts('Toggle Dotfiles'))
  keymap('n', 'I', api.tree.toggle_gitignore_filter, opts('Toggle Git Ignore'))
  keymap('n', 'J', api.node.navigate.sibling.last, opts('Last Sibling'))
  keymap('n', 'K', api.node.navigate.sibling.first, opts('First Sibling'))
  keymap('n', 'm', api.marks.toggle, opts('Toggle Bookmark'))
  keymap('n', 'o', api.node.open.edit, opts('Open'))
  keymap('n', 'O', api.node.open.no_window_picker, opts('Open: No Window Picker'))
  keymap('n', 'p', api.fs.paste, opts('Paste'))
  keymap('n', 'P', api.node.navigate.parent, opts('Parent Directory'))
  keymap('n', 'q', api.tree.close, opts('Close'))
  keymap('n', 'r', api.fs.rename, opts('Rename'))
  keymap('n', 'R', api.tree.reload, opts('Refresh'))
  keymap('n', 's', api.node.run.system, opts('Run System'))
  keymap('n', 'S', api.tree.search_node, opts('Search'))
  keymap('n', 'U', api.tree.toggle_custom_filter, opts('Toggle Hidden'))
  keymap('n', 'W', api.tree.collapse_all, opts('Collapse'))
  keymap('n', 'x', api.fs.cut, opts('Cut'))
  keymap('n', 'y', api.fs.copy.filename, opts('Copy Name'))
  keymap('n', 'Y', api.fs.copy.relative_path, opts('Copy Relative Path'))
  keymap('n', '<2-LeftMouse>', api.node.open.edit, opts('Open'))
  keymap('n', '<2-RightMouse>', api.tree.change_root_to_node, opts('CD'))

  --[[  自定义配置 ]]
  -- 进入目录
  keymap('n', '<CR>', api.tree.change_root_to_node, opts('CD'))
  -- 关闭目录
  keymap('n', '<Esc>', api.tree.close, opts('Close'))
  -- 展开目录
  keymap('n', '<Tab>', api.node.open.edit, opts('Open'))
  -- 上一个 git 文件
  keymap('n', '(', api.node.navigate.git.prev, opts('Prev Git'))
  -- 下一个 git 文件
  keymap('n', ')', api.node.navigate.git.next, opts('Next Git'))
  -- 下一个 dialog 文件
  keymap('n', '>', api.node.navigate.diagnostics.next, opts('Next Diagnostic'))
  -- 上一个 dialog 文件
  keymap('n', '<', api.node.navigate.diagnostics.prev, opts('Prev Diagnostic'))
  -- 下一个兄弟文件
  keymap('n', 'n', api.node.navigate.sibling.next, opts('Next Sibling'))
  -- 上一个兄弟文件
  keymap('n', 'N', api.node.navigate.sibling.prev, opts('Previous Sibling'))
  -- 帮助手册
  keymap('n', '?', api.tree.toggle_help, opts('Help'))
  -- 快速切换
  keymap('n', 'C', M.magicCd, opts('MagicCd'))
end

function M.config()
  vim.g.nvim_tree_firsttime = 1
  vim.cmd('hi! NvimTreeCursorLine cterm=NONE ctermbg=238')
  vim.cmd('hi! link NvimTreeFolderIcon NvimTreeFolderName')
  -- vim.cmd("au FileType NvimTree nnoremap <buffer> <silent> C :lua require('user.plugins.nvim-tree').magicCd()<cr>")
end

function M.setup()
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
      -- 浮动设置
      float = {
        enable = true,
        open_win_config = function()
          local columns = vim.o.columns
          local lines = vim.o.lines
          local width = math.max(math.floor(columns * 0.17), 20)
          local height = math.max(math.floor(lines * 0.6), 20)
          local left = math.ceil((columns - width) * 1)
          local top = math.ceil((lines - height) * 0.1 - 2)
          return { relative = 'editor', border = 'rounded', width = width, height = height, row = top, col = left }
        end,
      },
    },
    update_focused_file = {
      enable = true,
      update_root = false,
      ignore_list = {},
    },
    renderer = {
      group_empty = true,
      indent_markers = { enable = true },
      icons = {
        git_placement = 'after',
        webdev_colors = true,
        glyphs = {
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
    sync_root_with_cwd = true,
    respect_buf_cwd = true,
  }
end

return M
