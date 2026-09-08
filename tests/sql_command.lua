package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

require('plugins.format.conform')
local sql = require('plugins.format.sql')
local notifications = {}
local original_notify = vim.notify

local function assert_list(expected, actual)
  assert(#actual == #expected, ('expected %d items, got %d'):format(#expected, #actual))
  for i, value in ipairs(expected) do
    assert(actual[i] == value, ('expected item %d to be %s, got %s'):format(i, value, actual[i]))
  end
end

local function assert_notification(message, level)
  local notification = notifications[#notifications]
  assert(notification, 'expected a notification')
  assert(notification.message == message, ('expected notification %q, got %q'):format(message, notification.message))
  assert(notification.level == level, ('expected notification level %s, got %s'):format(level, notification.level))
end

local function new_buffer(filetype, lines)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].filetype = filetype
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines or {})
  return bufnr
end

local function formatter_dialect(bufnr)
  local args = sql.formatter('/fallback').args(nil, { buf = bufnr })
  for i, arg in ipairs(args) do
    if arg == '--dialect' then return args[i + 1] end
  end
end

local function run()
  vim.notify = function(message, level) notifications[#notifications + 1] = { message = message, level = level } end

  local supported = {
    'ansi',
    'athena',
    'bigquery',
    'clickhouse',
    'databricks',
    'db2',
    'doris',
    'duckdb',
    'exasol',
    'flink',
    'greenplum',
    'hive',
    'impala',
    'mariadb',
    'materialize',
    'mysql',
    'oracle',
    'postgres',
    'redshift',
    'snowflake',
    'soql',
    'sparksql',
    'sqlite',
    'starrocks',
    'teradata',
    'trino',
    'tsql',
    'vertica',
  }
  assert_list(supported, vim.fn.getcompletion('SqlDialect ', 'cmdline'))
  assert_list({ 'postgres' }, vim.fn.getcompletion('SqlDialect PO', 'cmdline'))

  local first = new_buffer('sql', { "comment on table akir_menu is '菜单表';" })
  vim.api.nvim_set_current_buf(first)
  vim.cmd('SqlDialect postgresql')
  assert(vim.b[first].sql_dialect == 'postgres')
  assert_notification('SQL dialect set to postgres', nil)
  assert(formatter_dialect(first) == 'postgres')

  vim.cmd('SqlDialect mssql')
  assert(vim.b[first].sql_dialect == 'tsql')
  vim.cmd('SqlDialect sqlserver')
  assert(vim.b[first].sql_dialect == 'tsql')
  vim.cmd('SqlDialect postgres')
  vim.cmd('SqlDialect')
  assert_notification('SQL dialect: postgres (buffer)', nil)

  vim.cmd('SqlDialect unsupported')
  assert(vim.b[first].sql_dialect == 'postgres')
  assert_notification('Unsupported SQL dialect: unsupported', vim.log.levels.ERROR)
  vim.cmd('SqlDialect! mysql')
  assert(vim.b[first].sql_dialect == 'postgres')
  assert_notification('SqlDialect! does not accept a dialect', vim.log.levels.ERROR)

  local second = new_buffer('sql', { 'select 1;' })
  vim.api.nvim_set_current_buf(second)
  assert(vim.b[second].sql_dialect == nil)
  vim.cmd('SqlDialect')
  assert_notification('SQL dialect: ansi (fallback)', nil)

  local non_sql = new_buffer('lua', { 'return true' })
  vim.api.nvim_set_current_buf(non_sql)
  vim.cmd('SqlDialect mysql')
  assert(vim.b[non_sql].sql_dialect == nil)
  assert_notification('SqlDialect is only available in SQL buffers', vim.log.levels.ERROR)

  vim.api.nvim_set_current_buf(first)
  vim.api.nvim_buf_set_lines(first, 0, -1, false, { '-- dialect: mysql', 'select 1;' })
  vim.cmd('SqlDialect!')
  assert(vim.b[first].sql_dialect == nil)
  assert_notification('SQL dialect override cleared; effective dialect: mysql (header)', nil)
end

local ok, err = xpcall(run, debug.traceback)
vim.notify = original_notify
if not ok then error(err) end

print('sql command tests passed')
