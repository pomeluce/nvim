local M = {}

M.Windows = 'Windows'
M.Linux = 'Linux'
M.Mac = 'Mac'

M.os_type = function()
  local has = vim.fn.has
  local t = M.Linux
  if has('win32') == 1 or has('win64') == 1 then
    t = M.Windows
  elseif has('mac') == 1 then
    t = M.Mac
  end
  return t
end

M.is_win = M.os_type() == M.Windows
M.is_linux = M.os_type() == M.Linux
M.is_mac = M.os_type() == M.Mac

return M
