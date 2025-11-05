local M = {}

M.is_windows = vim.fn.has('win32') ~= 0

M.cfg_path = vim.fn.stdpath('config')

return M
