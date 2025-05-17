return {
  cmd = { 'sql-language-server', 'up', '--method', 'stdio' },
  filetypes = { 'sql', 'mysql', 'mariadb', 'psql', 'sqlite', 'sqlite3', 'oracle', 'mssql' },
  single_file_support = true,
  settings = {
    sql = { dialect = 'ansi' },
    sqlLanguageServer = {
      -- 这个表定义了所有 lint 规则, 置空就相当于不检查格式
      lint = { rules = {} },
    },
  },
  on_new_config = function(new_config, root_dir)
    local dialect = vim.g.sql_dialect_override[root_dir]
    if dialect then
      new_config.settings.sql = new_config.settings.sql or {}
      new_config.settings.sql.dialect = dialect
    end
  end,

  on_init = function(client, _)
    local root_dir = client.config.root_dir
    local dialect = vim.g.sql_dialect_override[root_dir]
    if dialect then
      client.config.settings.sql = client.config.settings.sql or {}
      client.config.settings.sql.dialect = dialect
      client:notify('workspace/didChangeConfiguration', { settings = client.config.settings })
    end
  end,
}
