local M = {}

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

function M.DBUI()
  --[[
    laststatus: 移除状态行
    showtabline: 移除标签行
    nonu: 移除行号
    signcolumn: 移除标记列
    nofoldenable: 移除折叠
  ]]
  -- vim.cmd('set laststatus=0 showtabline=0 nonu signcolumn=no nofoldenable')
  vim.cmd('set nonu signcolumn=no nofoldenable')
  vim.cmd('exec "DBUI"')
end

function M.config()
  -- 窗口侧边栏宽度
  vim.g.db_ui_winwidth = 30
  -- 临时查询文件保存位置
  vim.g.db_ui_tmp_query_location = require('akirc').file.db_workspace
  -- 连接文件保存位置
  vim.g.db_ui_save_location = vim.fn.stdpath('config') .. '/cache/db_connections'
  -- 使用 nerd font
  vim.g.db_ui_use_nerd_fonts = 1
  -- 强制回显通知
  vim.g.db_ui_force_echo_notifications = 1
  -- 预定义方案
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
  -- 自动执行帮助程序查询
  vim.g.db_ui_auto_execute_table_helpers = 1

  -- 禁用默认快捷键映射
  -- vim.g.db_ui_disable_mappings = 1

  -- 禁用 dbui 窗口的默认快捷键映射, 改为自定义映射
  -- vim.g.db_ui_disable_mappings_dbui = 1
  -- local autocmd = vim.api.nvim_create_autocmd
  -- autocmd('FileType', {
  --   pattern = 'dbui',
  --   callback = function()
  --     vim.keymap.set('n', 'o', '<Plug>(DBUI_SelectLine)', { buffer = true })
  --     ...
  --   end,
  -- })

  -- 禁用 sql 窗口的默认快捷键映射, 改为自定义映射
  vim.g.db_ui_disable_mappings_sql = 1
  local autocmd = vim.api.nvim_create_autocmd
  autocmd('FileType', {
    pattern = 'sql',
    callback = function()
      vim.keymap.set({ 'n', 'v' }, '<c-cr>', '<Plug>(DBUI_ExecuteQuery)', { buffer = true })
    end,
  })

  vim.cmd('com! CALLDB lua require("user.configs.dadbod").DBUI()')
end

function M.setup()
  -- do nothing
end

return M
