local settings = require('settings').database

local pg_primary_keys = [[
select
  tc.constraint_name,
  tc.table_name,
  kcu.column_name,
  ccu.table_name  as foreigntbl_name,
  ccu.column_name as foreign_column_name,
  rc.update_rule,
  rc.delete_rule
from information_schema.table_constraints as tc
join information_schema.key_column_usage as kcu
  on tc.constraint_name = kcu.constraint_name
join information_schema.referential_constraints as rc
  on tc.constraint_name = rc.constraint_name
join information_schema.constraint_column_usage as ccu
  on ccu.constraint_name = tc.constraint_name
where constraint_type = 'PRIMARY KEY'
  and tc.table_name = '{table}'
  and tc.table_schema = '{schema}';
]]

local pg_indexes = [[
select
  tc.constraint_name,
  tc.table_name,
  kcu.column_name,
  pgi.indexdef as index_definition
from information_schema.table_constraints tc
join information_schema.key_column_usage kcu
  on tc.constraint_name = kcu.constraint_name
join pg_indexes pgi
  on tc.constraint_name = pgi.indexname
where tablename = '{table}'
  and schemaname = '{schema}';
]]

local pg_references = [[
select
  tc.constraint_name,
  tc.table_name,
  kcu.column_name,
  ccu.table_name  as foreign_table_name,
  ccu.column_name as foreign_column_name,
  rc.update_rule,
  rc.delete_rule
from information_schema.table_constraints as tc
join information_schema.key_column_usage as kcu
  on tc.constraint_name = kcu.constraint_name
join information_schema.referential_constraints as rc
  on tc.constraint_name = rc.constraint_name
join information_schema.constraint_column_usage as ccu
  on tc.constraint_name = ccu.constraint_name
where constraint_type = 'FOREIGN KEY'
  and ccu.table_name = '{table}'
  and ccu.table_schema = '{schema}';
]]

local pg_foreign_keys = [[
select distinct
  tc.constraint_name,
  tc.table_name,
  kcu.column_name,
  ccu.table_name  as foreign_table_name,
  ccu.column_name as foreign_column_name,
  rc.update_rule,
  rc.delete_rule
from information_schema.table_constraints as tc
join information_schema.key_column_usage as kcu
  on tc.constraint_name = kcu.constraint_name
join information_schema.referential_constraints as rc
  on tc.constraint_name = rc.constraint_name
join information_schema.constraint_column_usage as ccu
  on tc.constraint_name = ccu.constraint_name
where constraint_type = 'FOREIGN KEY'
  and tc.table_name = '{table}'
  and tc.table_schema = '{schema}';
]]

vim.g.db_ui_winwidth = 30
vim.g.db_ui_tmp_query_location = settings.query_location
vim.g.db_ui_save_location = vim.fn.stdpath('config') .. '/cache/db_connections'
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_force_echo_notifications = 1
vim.g.db_ui_execute_on_save = 0
vim.g.db_ui_table_helpers = {
  mysql = {
    ['List'] = 'select * from `{schema}`.`{table}` limit 500;',
    ['Indexes'] = 'show indexes from `{schema}`.`{table}`;',
    ['Table Fields'] = 'describe `{schema}`.`{table}`;',
    ['Alter Table'] = 'alter table `{schema}`.`{table}` add ',
  },
  postgresql = {
    ['List'] = 'select * from {schema}.{table} limit 500;',
    ['Columns'] = '\\d+ {schema}.{table}',
    ['Primary Keys'] = pg_primary_keys,
    ['Indexes'] = pg_indexes,
    ['References'] = pg_references,
    ['Foreign Keys'] = pg_foreign_keys,
    ['Alter Table'] = 'alter table {schema}.{table} add ',
  },
}
vim.g.db_ui_auto_execute_table_helpers = 1
vim.g.db_ui_disable_mappings_sql = 1

local function load_dadbod()
  local loaded = PackUtils.load({
    name = 'vim-dadbod-ui',
    deps = { 'vim-dadbod', 'vim-dadbod-completion' },
  })
  return loaded
end

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = load_dadbod,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'mysql', 'plsql', 'redis', 'sql' },
  callback = function()
    vim.keymap.set({ 'n', 'v' }, '<C-CR>', '<Plug>(DBUI_ExecuteQuery)', { buffer = true })
    vim.keymap.set({ 'n', 'v' }, '<M-CR>', '<Plug>(DBUI_ExecuteQuery)', { buffer = true })
  end,
})

vim.api.nvim_create_user_command('CALLDB', function()
  if not load_dadbod() then return end
  vim.cmd('set nonu signcolumn=no nofoldenable')
  vim.cmd('DBUI')
end, { nargs = '*' })
