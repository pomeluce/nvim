local M = {}

---@param repo string
---@param cmd string[]
function M.pack_build(repo, cmd)
  for _, plugin in ipairs(vim.pack.get()) do
    if plugin.spec.src and plugin.spec.src:match(repo) then
      local marker = plugin.path .. '/.build_done'
      if vim.fn.filereadable(marker) == 1 then return end
      local result = vim.system(cmd, { cwd = plugin.path }):wait()
      if result.code == 0 then
        vim.fn.writefile({ 'ok' }, marker)
      else
        vim.notify('Build failed for ' .. plugin.spec.src, vim.log.levels.ERROR)
      end
    end
  end
end

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

---@param path string
---@return any|nil
function M.settings(path)
  local tbl = M.read_json(vim.fn.stdpath('config') .. '/settings.json')
  if type(tbl) ~= 'table' or type(path) ~= 'string' then return nil end

  local current = tbl

  for key in string.gmatch(path, '[^%.]+') do
    if type(current) ~= 'table' then return nil end

    current = current[key]

    if current == nil then return nil end
  end

  return current
end

M.is_win = vim.fn.has('win32') ~= 0
M.is_mac = vim.fn.has('macunix') ~= 0
M.is_unix = vim.fn.has('unix') ~= 0 and not M.is_mac

return M
