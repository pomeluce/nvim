local utils = require('utils')

---@class settings.Session
---@field projects string[]
---@field ignore_dir string[]

---@class settings.Lsp.Jdtls.Maven
---@field userSettings? string
---@field globalSettings? string

---@class settings.Lsp.Jdtls.Runtime
---@field name string
---@field path string
---@field default? boolean

---@class settings.Lsp.Jdtls
---@field maven settings.Lsp.Jdtls.Maven
---@field runtimes settings.Lsp.Jdtls.Runtime[]

---@class settings.Lsp
---@field jdtls? settings.Lsp.Jdtls

---@class settings.Mason
---@field enable boolean

---@class settings.File
---@field run_cmd table<string, string>

---@class settings.Root
---@field session settings.Session
---@field lsp settings.Lsp
---@field mason settings.Mason
---@field file settings.File

local function parse_value(raw)
  raw = raw:match('^%s*(.-)%s*$')
  if raw:match('^".*"$') then
    return raw:sub(2, -2)
  elseif raw == 'true' then
    return true
  elseif raw == 'false' then
    return false
  elseif raw:match('^%d+%.?%d*$') then
    return tonumber(raw)
  elseif raw:match('^%[') then
    local arr = {}
    for item in raw:gmatch('"([^"]*)"') do
      arr[#arr + 1] = item
    end
    return arr
  end
  return raw
end

local function parse_toml(content)
  local result = {}
  local current = result

  local function get_or_create(tbl, path)
    for key in path:gmatch('[^%.]+') do
      tbl[key] = tbl[key] or {}
      tbl = tbl[key]
    end
    return tbl
  end

  local function get_parent(tbl, path)
    local keys = {}
    for k in path:gmatch('[^%.]+') do
      keys[#keys + 1] = k
    end
    for i = 1, #keys - 1 do
      tbl[keys[i]] = tbl[keys[i]] or {}
      tbl = tbl[keys[i]]
    end
    return tbl, keys[#keys]
  end

  for line in content:gmatch('[^\r\n]+') do
    if not (line:match('^%s*$') or line:match('^%s*#')) then
      local array_path = line:match('^%s*%[%[(.+)%]%]')
      if array_path then
        local parent, key = get_parent(result, array_path)
        parent[key] = parent[key] or {}
        parent[key][#parent[key] + 1] = {}
        current = parent[key][#parent[key]]
      else
        local table_path = line:match('^%s*%[(.+)%]')
        if table_path then
          current = get_or_create(result, table_path)
        else
          local k, v = line:match('^%s*([%w_]+)%s*=%s*(.+)')
          if k then current[k] = parse_value(v) end
        end
      end
    end
  end

  return result
end

local function load_toml()
  local content = utils.read_file(vim.fn.stdpath('config') .. '/settings.toml')
  return content and parse_toml(content) or {}
end

---@type settings.Root
local defaults = {
  session = {
    projects = {},
    ignore_dir = {},
  },
  lsp = {
    jdtls = {
      maven = {},
      runtimes = {},
    },
  },
  mason = { enable = false },
  file = { run_cmd = {} },
}

return vim.tbl_deep_extend('force', defaults, load_toml())

