local M = {}

M.cfg_path = vim.fn.stdpath('config')

M.is_windows = vim.fn.has('win32') ~= 0

return M
