local M = {}

local function netrw_path()
  local dir = vim.b.netrw_curdir
  if not dir or dir:find('://', 1, true) or vim.fn.line('.') < (vim.w.netrw_bannercnt or 1) then return end
  local view = vim.fn.winsaveview()
  local name = vim.fn['netrw#Call']('NetrwGetWord')
  vim.fn.winrestview(view)
  if name ~= '' then
    if vim.w.netrw_treetop and vim.w.netrw_liststyle == 3 and name ~= '../' then
      dir = vim.fn['netrw#Call']('NetrwTreePath', vim.w.netrw_treetop)
      -- For directory entries, netrw already includes the entry in the tree path.
      if vim.fs.basename(vim.fs.normalize(dir)) == name:gsub('/$', '') then return dir end
    end
    return vim.fs.joinpath(dir, name)
  end
end

local explorers = {
  NvimTree = function()
    local node = require('nvim-tree.api').tree.get_node_under_cursor()
    return node and node.absolute_path
  end,
  ['neo-tree'] = function()
    local state = require('neo-tree.sources.manager').get_state_for_window()
    local node = state and state.tree and state.tree:get_node()
    return node and node.path
  end,
  oil = function()
    local oil = require('oil')
    local dir, entry = oil.get_current_dir(), oil.get_cursor_entry()
    return dir and entry and vim.fs.joinpath(dir, entry.name)
  end,
  minifiles = function()
    local entry = require('mini.files').get_fs_entry()
    return entry and entry.path
  end,
  netrw = netrw_path,
}

function M.tree_path()
  local lookup = explorers[vim.bo.filetype]
  if lookup then
    local ok, path = pcall(lookup)
    if ok and type(path) == 'string' and path ~= '' and not path:find('://', 1, true) then return vim.fs.abspath(path) end
  end
end

function M.buffer_path()
  local name = vim.api.nvim_buf_get_name(0)
  if vim.bo.buftype == '' and name ~= '' and not name:find('://', 1, true) then return name end
end

local function git_root(path)
  local candidate = vim.fs.root(path, '.git')
  while candidate do
    local marker = vim.fs.joinpath(candidate, '.git')
    local stat = vim.uv.fs_stat(marker)
    if stat and (stat.type == 'file' or vim.uv.fs_stat(vim.fs.joinpath(marker, 'HEAD'))) then return candidate end
    local parent = vim.fs.dirname(candidate)
    candidate = parent and parent ~= candidate and vim.fs.root(parent, '.git') or nil
  end
end

function M.root(path)
  local cwd = vim.fn.getcwd()
  local root = vim.b.codex_root or git_root(path or M.buffer_path() or M.tree_path() or cwd) or cwd
  return vim.uv.fs_realpath(root) or vim.fs.normalize(root)
end

function M.path_label(root, path) return vim.fs.relpath(root, path) or path end

function M.path_reference(root, path, start_line, end_line)
  local label = M.path_label(root, path)
  if start_line then label = ('%s#L%d'):format(label, start_line) end
  if end_line and end_line ~= start_line then label = ('%s-%d'):format(label, end_line) end
  if label:find('%s') then label = '"' .. label:gsub('"', '\\"') .. '"' end
  return label .. ' '
end

function M.selection(opts)
  local mode = vim.fn.mode()
  local first, last = vim.fn.getpos('v'), vim.fn.getpos('.')
  local lines
  if mode == 'v' or mode == 'V' or mode == '\22' then
    lines = vim.fn.getregion(first, last, {
      type = mode,
      exclusive = vim.o.selection == 'exclusive',
    })
    -- getregionpos accounts for exclusive selections ending at column one.
    local positions = vim.fn.getregionpos(first, last, {
      type = mode,
      exclusive = vim.o.selection == 'exclusive',
    })
    first, last = positions[1][1], positions[#positions][2]
  elseif opts.range > 0 then
    first, last = { 0, opts.line1 }, { 0, opts.line2 }
    lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
  end
  if not lines then return end

  local start_line, end_line = math.min(first[2], last[2]), math.max(first[2], last[2])
  local path = M.buffer_path()
  local text = table.concat(lines, '\n')
  return text, path, start_line, end_line
end

return M
