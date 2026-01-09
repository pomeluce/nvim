local M = {}

function M.map(mode, lhs, rhs, opts) vim.keymap.set(mode, lhs, rhs, vim.tbl_extend('force', { silent = true }, opts or {})) end

M.is_win = vim.fn.has('win32') ~= 0
M.is_mac = vim.fn.has('macunix') ~= 0
M.is_unix = vim.fn.has('unix') ~= 0 and not M.is_mac

return M
