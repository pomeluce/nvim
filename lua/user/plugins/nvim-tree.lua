local M = {}

-- 有时候进入到依赖文件内，此时想在依赖文件所在目录查看文件 nvim-tree 并没有一个很好的方法，所以写了这个func
local inner_cwd = ""
local outer_cwd = ""
function M.magicCd()
  local api = require("nvim-tree.api")
  local core = require("nvim-tree.core")

  local file_path = vim.fn.expand('#:p:h')
  local tree_cwd = core.get_cwd()

  if inner_cwd == "" then
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
    if outer_cwd ~= "" then
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

function M.config()
  vim.g.nvim_tree_firsttime = 1
  vim.cmd("hi! NvimTreeCursorLine cterm=NONE ctermbg=238")
  vim.cmd("hi! link NvimTreeFolderIcon NvimTreeFolderName")
  vim.cmd("au FileType NvimTree nnoremap <buffer> <silent> C :lua require('user.plugins.nvim-tree').magicCd()<cr>")
end

function M.setup()
  local status_ok, nvim_tree = pcall(require, "nvim-tree")
  if not status_ok then
    vim.notify("nvim-tree 没有加载或者未安装")
    return
  end
  ---@diagnostic disable-next-line: redundant-parameter
  nvim_tree.setup({
    sort_by = "case_sensitive",
    -- 在多个窗口下打开 buffer 时, 默认使用最近窗口
    actions = {
      open_file = {
        window_picker = { enable = false }
      }
    },
    view = {
      mappings = {
        list = {
          -- 进入目录
          { key = "<CR>", action = "cd" },
          -- 返回上一级目录
          { key = "<BS>", action = "dir_up" },
          -- 关闭目录
          { key = "<Esc>", action = "close" },
          -- 展开目录
          { key = "<Tab>", action = "expand" },
          -- 展开目录
          { key = "<Right>", action = "expand" },
          -- 关闭目录树
          { key = "<Left>", action = "close_node" },
          -- 下一个 git 文件
          { key = ")", action = "next_git_item" },
          -- 上一个 git 文件
          { key = "(", action = "prev_git_item" },
          -- 下一个 dialog 文件
          { key = ">", action = "next_diag_item" },
          -- 上一个 dialog 文件
          { key = "<", action = "prev_diag_item" },
          -- 上一个兄弟文件
          { key = "N", action = "prev_sibling" },
          -- 下一个兄弟文件
          { key = "n", action = "next_sibling" },
          -- 帮助手册
          { key = "?", action = "toggle_help" },
          -- 创建文件
          { key = "A", action = "create" },
          -- 内外文件目录切换
          { key = "C", action = "" },
        },
      },
      -- 浮动设置
      float = {
        enable = true,
        open_win_config = function()
          local columns = vim.o.columns
          local lines = vim.o.lines
          local width = math.max(math.floor(columns * 0.5), 50)
          local height = math.max(math.floor(lines * 0.5), 20)
          local left = math.ceil((columns - width) * 0.5)
          local top = math.ceil((lines - height) * 0.5 - 2)
          return { relative = "editor", border = "rounded", width = width, height = height, row = top, col = left }
        end,
      }
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
        git_placement = "after", webdev_colors = true,
        glyphs = { git = { unstaged = "~", staged = "✓", unmerged = "", renamed = "+", untracked = "?",
          deleted = "", ignored = " " } }
      }
    },
    filters = { dotfiles = true },
    diagnostics = {
      enable = true, show_on_dirs = true, debounce_delay = 50,
      icons = { hint = "", info = "", warning = "", error = "" }
    },
  })
end

return M
