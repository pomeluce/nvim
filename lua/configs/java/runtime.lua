local M = {}

local aliases = { ['8'] = '1.8', ['1.8'] = '8' }

local function read_version(pom)
  local file = io.open(pom, 'r')
  if not file then return end
  local content = file:read('*a')
  file:close()
  return content:match('<java%.version>%s*([^<%s]+)%s*</java%.version>')
    or content:match('<maven%.compiler%.release>%s*([^<%s]+)%s*</maven%.compiler%.release>')
    or content:match('<maven%.compiler%.source>%s*([^<%s]+)%s*</maven%.compiler%.source>')
    or content:match('<source>%s*([^<$%s][^<]*)%s*</source>')
    or content:match('<target>%s*([^<$%s][^<]*)%s*</target>')
end

local function matches(runtime_version, version) return runtime_version == version or runtime_version == aliases[version] end

function M.buffer_version(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local pom = vim.fs.find('pom.xml', { path = vim.fs.dirname(filename), upward = true, type = 'file' })[1]
  return pom and read_version(pom) or nil
end

function M.project_runtimes(root_dir, runtimes)
  local result = vim.deepcopy(runtimes)
  local version = read_version(root_dir .. '/pom.xml')
  if not version then return result end

  local matched = false
  for _, runtime in ipairs(result) do
    local runtime_version = runtime.name:match('^JavaSE%-(.+)$')
    local selected = matches(runtime_version, version)
    runtime.default = selected or nil
    matched = matched or selected
  end
  if not matched then vim.notify(('No JavaSE-%s runtime configured for %s'):format(version, root_dir), vim.log.levels.WARN) end
  return result
end

function M.java_home(runtimes, compliance)
  if compliance then
    local version = tostring(compliance)
    for _, runtime in ipairs(runtimes) do
      if matches(runtime.name:match('^JavaSE%-(.+)$'), version) then return runtime.path end
    end
  end
  for _, runtime in ipairs(runtimes) do
    if runtime.default then return runtime.path end
  end
  return runtimes[1] and runtimes[1].path or nil
end

return M
