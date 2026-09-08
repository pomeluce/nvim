package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

local sql = require('plugins.format.sql')

local function assert_resolution(expected_dialect, expected_source, opts)
  local dialect, source = sql.resolve(opts)
  assert(dialect == expected_dialect, ('expected dialect %s, got %s'):format(expected_dialect, dialect))
  assert(source == expected_source, ('expected source %s, got %s'):format(expected_source, source))
end

assert_resolution('postgres', 'buffer', {
  buffer_dialect = 'postgresql',
  lines = { '-- dialect: mysql', 'select 1;' },
  project_config = '[sqlfluff]\ndialect = sqlite',
})

assert_resolution('mysql', 'header', {
  lines = { '-- sql-dialect: mysql', 'select 1::int;' },
  project_config = '[sqlfluff]\ndialect = sqlite',
})

assert_resolution('sqlite', 'project', {
  lines = { 'select 1::int;' },
  project_config = '[sqlfluff]\ndialect = sqlite\n[sqlfluff:indentation]\ntab_space_size = 2',
})

local syntax_cases = {
  postgres = { 'do $$', 'begin', '  perform 1;', 'end', '$$;' },
  mysql = { 'create table users (id int auto_increment);' },
  sqlite = { 'pragma foreign_keys = on;' },
  tsql = { 'select 1;', 'go', 'select 2;' },
  oracle = { 'create table users (name varchar2(100));' },
  bigquery = { 'select safe_cast(value as int64) from events;' },
  snowflake = { 'select * from table(flatten(input => payload));' },
}

for expected, lines in pairs(syntax_cases) do
  assert_resolution(expected, 'syntax', { lines = lines })
end

assert_resolution('ansi', 'fallback', { lines = { 'select * from users;' } })
assert_resolution('ansi', 'fallback', { lines = { 'select value::int from t;', 'pragma foreign_keys = on;' } })
assert_resolution('ansi', 'fallback', { lines = { '-- pragma foreign_keys = on;', "select 'language plpgsql';" } })
assert_resolution('mysql', 'header', {
  buffer_dialect = 'unsupported',
  lines = { '-- dialect: mysql', 'select 1;' },
})
assert_resolution('sqlite', 'project', {
  lines = { '-- dialect: unsupported', 'select 1;' },
  project_config = '[sqlfluff]\ndialect = sqlite',
})
assert_resolution('postgres', 'syntax', {
  lines = { 'select 1::int;' },
  project_config = '[sqlfluff]\ndialect = unsupported',
})

print('sql dialect tests passed')
