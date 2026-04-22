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

M.lsp = {
  ---@param name  string
  ---@param config vim.lsp.Config
  ---@return vim.lsp.Config
  config_merge = function(name, config)
    local is_ok, project_config = pcall(dofile, vim.fn.getcwd() .. '/.nvim/' .. name .. '.lua')
    return vim.tbl_deep_extend('force', config, is_ok and project_config or {})
  end,

  ---@param pattern string|string[]
  ---@param server string|string[]
  enable_server = function(pattern, server)
    vim.api.nvim_create_autocmd('FileType', {
      pattern = pattern,
      callback = function() vim.lsp.enable(server) end,
    })
  end,
}

local is_win = vim.fn.has('win32') ~= 0
local is_mac = vim.fn.has('macunix') ~= 0
M.platform = {
  is_win = is_win,
  is_mac = is_mac,
  is_unix = vim.fn.has('unix') ~= 0 and not is_mac,
}

return M
