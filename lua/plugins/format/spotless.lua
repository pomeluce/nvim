local Spotless = {}

local function find_upward_file(ctx, names)
  local dir = ctx.dirname
  while dir do
    for _, name in ipairs(names) do
      local path = vim.fs.joinpath(dir, name)
      if vim.fn.filereadable(path) == 1 then return path end
    end
    local parent = vim.fs.dirname(dir)
    if not parent or parent == dir then break end
    dir = parent
  end
  return nil
end

local function read_file(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then return nil end
  return table.concat(lines, '\n')
end

local function context(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local dirname = filename ~= '' and vim.fs.dirname(filename) or nil
  return dirname and { filename = filename, dirname = dirname, buf = bufnr } or nil
end

local function find_nearest_pom(ctx) return find_upward_file(ctx, { 'pom.xml' }) end

local function find_maven_wrapper(ctx)
  local names = vim.fn.has('win32') == 1 and { 'mvnw.cmd', 'mvnw' } or { 'mvnw' }
  local dir = ctx.dirname
  while dir do
    for _, name in ipairs(names) do
      local wrapper = vim.fs.joinpath(dir, name)
      if vim.fn.filereadable(wrapper) == 1 and (vim.fn.has('win32') == 1 or vim.fn.executable(wrapper) == 1) then return wrapper end
    end
    local parent = vim.fs.dirname(dir)
    if not parent or parent == dir then break end
    dir = parent
  end
  return nil
end

local function xml_element(content, name)
  if content:match('<' .. name .. '%s*/>') then return '' end
  return content:match('<' .. name .. '>%s*(.-)%s*</' .. name .. '>')
end

local function parent_pom(pom)
  local content = read_file(pom)
  if not content then return nil end
  local parent = content:match('<parent>%s*(.-)%s*</parent>')
  if not parent then return nil end

  ---@type string|nil
  local relative_path = xml_element(parent, 'relativePath')
  if relative_path == '' then return nil end
  relative_path = relative_path or '../pom.xml'
  local path = vim.fs.normalize(vim.fs.joinpath(vim.fs.dirname(pom), relative_path))
  return vim.fn.filereadable(path) == 1 and path or nil
end

local function find_spotless_maven(ctx)
  local module_pom = find_nearest_pom(ctx)
  if not module_pom then return nil end

  local visited = {}
  ---@type string|nil
  local pom = module_pom
  while pom and not visited[pom] do
    visited[pom] = true
    local content = read_file(pom)
    if content and (content:find('spotless%-maven%-plugin') or content:find('com%.diffplug%.spotless')) then return { module_pom = module_pom, pom = pom } end
    pom = parent_pom(pom)
  end
  return nil
end

local function spotless_formats_xml(content)
  local normalized = content:lower()
  if normalized:find('<xml[%s>]') then return true end
  local formats = content:match('<formats>%s*(.-)%s*</formats>')
  if not formats then return false end
  return formats:lower():find('%.xml') ~= nil
end

local function find_spotless_xml(ctx)
  local module_pom = find_nearest_pom(ctx)
  if not module_pom then return nil end

  local visited = {}
  ---@type string|nil
  local pom = module_pom
  local has_spotless_plugin = false
  local has_xml_format = false
  while pom and not visited[pom] do
    visited[pom] = true
    local content = read_file(pom)
    if content then
      has_spotless_plugin = has_spotless_plugin or content:find('spotless%-maven%-plugin') ~= nil or content:find('com%.diffplug%.spotless') ~= nil
      has_xml_format = has_xml_format or spotless_formats_xml(content)
    end
    if has_spotless_plugin and has_xml_format then return { module_pom = module_pom, pom = pom } end
    pom = parent_pom(pom)
  end
  return nil
end

local function has_spotless_gradle_config(ctx)
  local gradle_root_file = find_upward_file(ctx, { 'gradlew' })
  if not gradle_root_file then return false end
  local root = vim.fs.dirname(gradle_root_file)
  local dir = ctx.dirname
  while dir do
    for _, name in ipairs({ 'build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts', 'gradle/libs.versions.toml' }) do
      local path = vim.fs.joinpath(dir, name)
      if vim.fn.filereadable(path) == 1 then
        local ok, lines = pcall(vim.fn.readfile, path)
        if ok and string.find(table.concat(lines, '\n'), 'spotless') then return true end
      end
    end
    if dir == root then break end
    local parent = vim.fs.dirname(dir)
    if not parent or parent == dir then break end
    dir = parent
  end
  return false
end

function Spotless.spec()
  return {
    by_ft = {
      java = function(bufnr)
        local ctx = context(bufnr)
        if not ctx then return { 'clang-format' } end
        if find_spotless_maven(ctx) then return { 'spotless_maven' } end
        if has_spotless_gradle_config(ctx) then return { 'spotless_gradle' } end
        return { 'clang-format' }
      end,
      xml = function(bufnr)
        local ctx = context(bufnr)
        if not ctx then return { lsp_format = 'fallback' } end
        if find_spotless_xml(ctx) then return { 'spotless_maven' } end
        return { lsp_format = 'fallback' }
      end,
    },
    formatters = {
      spotless_gradle = {
        condition = function(_, ctx) return has_spotless_gradle_config(ctx) end,
      },
      spotless_maven = {
        condition = function(_, ctx) return find_spotless_maven(ctx) ~= nil end,
        command = function(_, ctx) return find_maven_wrapper(ctx) or 'mvn' end,
        cwd = function(_, ctx)
          local wrapper = find_maven_wrapper(ctx)
          if wrapper then return vim.fs.dirname(wrapper) end
          local module_pom = find_nearest_pom(ctx)
          return module_pom and vim.fs.dirname(module_pom) or nil
        end,
        args = function(self, ctx)
          local args = require('conform.formatters.spotless_maven').args(self, ctx)
          local maven = find_spotless_maven(ctx)
          if maven then
            table.insert(args, 1, maven.module_pom)
            table.insert(args, 1, '-f')
            table.insert(args, 3, '-N')
          end
          return args
        end,
      },
    },
  }
end

return Spotless
