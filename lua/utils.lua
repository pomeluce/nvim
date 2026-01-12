local M = {}

---@param modes string|string[] Mode "short-name" (see |nvim_set_keymap()|), or a list thereof.
---@param lhs string           Left-hand side |{lhs}| of the mapping.
---@param rhs string|function  Right-hand side |{rhs}| of the mapping, can be a Lua function.
---@param opts? vim.keymap.set.Opts
function M.map(modes, lhs, rhs, opts) vim.keymap.set(modes, lhs, rhs, vim.tbl_extend('force', { silent = true }, opts or {})) end

---@param path string
---@return string|nil
function M.read_file(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then return nil end
  return table.concat(lines, '\n')
end

---@param pattern string|string[]
---@param server string|string[]
function M.lsp_enable(pattern, server)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = pattern,
    callback = function() vim.lsp.enable(server) end,
  })
end

M.is_win = vim.fn.has('win32') ~= 0
M.is_mac = vim.fn.has('macunix') ~= 0
M.is_unix = vim.fn.has('unix') ~= 0 and not M.is_mac

return M
