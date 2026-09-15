package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

local settings_content = '[mason]\nenable = false'
package.loaded.utils = { read_file = function() return settings_content end }

local load_settings = assert(loadfile('./lua/settings.lua'))
local default_settings = load_settings()
assert(default_settings.database.query_location == vim.fn.stdpath('data') .. '/db_ui/queries')

settings_content = '[database]\nquery_location = "/custom/db-ui-queries"'
local custom_settings = load_settings()
assert(custom_settings.database.query_location == '/custom/db-ui-queries')

local query_location = '/tmp/akvim-db-ui-queries'
package.loaded.settings = { database = { query_location = query_location } }

local load_count = 0
local dbui_count = 0

_G.PackUtils = {
  load = function(spec)
    assert(debug.getinfo(2, 'Sl'), 'PackUtils.load caller frame is unavailable')
    assert(spec.name == 'vim-dadbod-ui')
    assert(vim.deep_equal(spec.deps, { 'vim-dadbod', 'vim-dadbod-completion' }))
    load_count = load_count + 1
    if vim.fn.exists(':DBUI') == 0 then vim.api.nvim_create_user_command('DBUI', function() dbui_count = dbui_count + 1 end, {}) end
    return true
  end,
}

local startup = require('core.startup')
require('plugins.tools.database')
startup.resolve({ 'nvim', '+CALLDB' })

assert(vim.g.db_ui_tmp_query_location == query_location)
assert(vim.g.db_ui_winwidth == 30)
assert(vim.g.db_ui_disable_mappings_sql == 1)
assert(vim.g.db_ui_table_helpers.mysql.List:find('limit 500', 1, true))
assert(vim.g.db_ui_table_helpers.postgresql['Primary Keys']:find("constraint_type = 'PRIMARY KEY'", 1, true))
assert(startup.is_tool_launch())

vim.api.nvim_exec_autocmds('VimEnter', {})
assert(load_count == 1)

vim.cmd('CALLDB')
assert(load_count == 2)
assert(dbui_count == 1)

local bufnr = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(bufnr)
vim.bo[bufnr].filetype = 'sql'
assert(vim.fn.maparg('<C-CR>', 'n', false, true).rhs == '<Plug>(DBUI_ExecuteQuery)')
assert(vim.fn.maparg('<M-CR>', 'x', false, true).rhs == '<Plug>(DBUI_ExecuteQuery)')

print('database tests passed')
