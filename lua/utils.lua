local M = {}

M.is_windows = vim.fn.has('win32') ~= 0

return M
