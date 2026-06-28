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

---@class settings.Header
---@field python? string
---@field lua? string
---@field javascript? string
---@field java? string
---@field kotlin? string
---@field scala? string
---@field go? string
---@field csharp? string
---@field c? string
---@field rust? string
---@field ruby? string
---@field bash? string
---@field swift? string
---@field zig? string

---@class settings.Root
---@field header settings.Header
---@field session settings.Session
---@field lsp settings.Lsp
---@field mason settings.Mason
---@field file settings.File

local tomlua = require('tomlua')

---@type settings.Root
local defaults = {
  header = {},
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

local function load_toml()
  local content = utils.read_file(vim.fn.stdpath('config') .. '/settings.toml')
  if not content then return defaults end
  local data, err = tomlua.decode(content, defaults)
  if err then
    vim.notify('settings.toml parse error: ' .. err, vim.log.levels.ERROR)
    return defaults
  end
  return data
end

return load_toml()
