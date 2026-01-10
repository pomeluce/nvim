local M = {}

function M.map(mode, lhs, rhs, opts) vim.keymap.set(mode, lhs, rhs, vim.tbl_extend('force', { silent = true }, opts or {})) end

function M.read_file(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then return nil end
  return table.concat(lines, '\n')
end

M.is_win = vim.fn.has('win32') ~= 0
M.is_mac = vim.fn.has('macunix') ~= 0
M.is_unix = vim.fn.has('unix') ~= 0 and not M.is_mac

return M
