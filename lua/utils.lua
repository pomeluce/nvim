local M = {}

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

---@param file string
---@return nil|table
function M.read_json(file)
  local f = io.open(file, 'r')
  if not f then return nil end

  local file_content = f:read('*all') -- Read entire file contents
  f:close()

  local ok, json = pcall(vim.json.decode, file_content)
  if not ok then return nil end

  return json
end

M.is_win = vim.fn.has('win32') ~= 0
M.is_mac = vim.fn.has('macunix') ~= 0
M.is_unix = vim.fn.has('unix') ~= 0 and not M.is_mac

return M
