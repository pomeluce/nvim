package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

local sql = require('plugins.format.sql')
local test_root = vim.fn.tempname()

local function path(...) return vim.fs.joinpath(test_root, ...) end

local function write_file(filename, content)
  vim.fn.mkdir(vim.fs.dirname(filename), 'p')
  assert(vim.fn.writefile(vim.split(content, '\n', { plain = true }), filename) == 0)
end

local function context_for(filename, lines)
  write_file(filename, table.concat(lines, '\n'))
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(bufnr, filename)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  return { filename = filename, dirname = vim.fs.dirname(filename), buf = bufnr }
end

local function assert_list(expected, actual)
  assert(#actual == #expected, ('expected %d items, got %d'):format(#expected, #actual))
  for i, value in ipairs(expected) do
    assert(actual[i] == value, ('expected item %d to be %s, got %s'):format(i, value, actual[i]))
  end
end

local function run()
  vim.fn.mkdir(test_root, 'p')

  local fallback_config = path('fallback')
  local formatter = sql.formatter(fallback_config)
  local postgres_ctx = context_for(path('standalone', 'procedure.sql'), { 'do $$', 'begin', '  null;', 'end', '$$;' })
  assert_list({
    'format',
    '--stdin-filename',
    '$FILENAME',
    '--config',
    path('fallback', 'sqlfluff.cfg'),
    '--dialect',
    'postgres',
    '-',
  }, formatter.args(nil, postgres_ctx))

  write_file(path('project', '.sqlfluff'), '[sqlfluff]\ndialect = mysql')
  local project_ctx = context_for(path('project', 'queries', 'generic.sql'), { 'select 1;' })
  assert_list({ 'format', '--stdin-filename', '$FILENAME', '--dialect', 'mysql', '-' }, formatter.args(nil, project_ctx))

  local header_ctx = context_for(path('project', 'queries', 'override.sql'), { '-- dialect: postgres', 'select 1;' })
  assert_list({ 'format', '--stdin-filename', '$FILENAME', '--dialect', 'postgres', '-' }, formatter.args(nil, header_ctx))
end

local ok, err = xpcall(run, debug.traceback)
vim.fn.delete(test_root, 'rf')
if not ok then error(err) end

print('sql formatter tests passed')
