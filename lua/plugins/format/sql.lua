local Sql = {}

local DIALECT_ALIASES = {
  mssql = 'tsql',
  postgresql = 'postgres',
  sqlserver = 'tsql',
}

local SUPPORTED_DIALECTS = {
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

local SUPPORTED_DIALECT_SET = {}
for _, dialect in ipairs(SUPPORTED_DIALECTS) do
  SUPPORTED_DIALECT_SET[dialect] = true
end

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

local function normalize_dialect(value)
  if type(value) ~= 'string' then return nil end
  local dialect = value:lower():match('^%s*([%a][%w_-]*)%s*$')
  dialect = dialect and (DIALECT_ALIASES[dialect] or dialect) or nil
  return dialect and SUPPORTED_DIALECT_SET[dialect] and dialect or nil
end

local function header_dialect(lines)
  for i = 1, math.min(#lines, 5) do
    local line = lines[i]:lower()
    local dialect = line:match('^%s*%-%-%s*dialect%s*:%s*([%w_-]+)') or line:match('^%s*%-%-%s*sql[_-]dialect%s*:%s*([%w_-]+)')
    dialect = normalize_dialect(dialect)
    if dialect then return dialect end
  end
  return nil
end

local function config_dialect(content)
  if type(content) ~= 'string' then return nil end
  local in_sqlfluff = false
  for line in (content .. '\n'):gmatch('(.-)\r?\n') do
    local section = line:match('^%s*%[([^]]+)%]%s*[#;]?.*$')
    if section then
      in_sqlfluff = section:lower() == 'sqlfluff'
    elseif in_sqlfluff then
      local value = line:match('^%s*[Dd][Ii][Aa][Ll][Ee][Cc][Tt]%s*=%s*([^#;]+)')
      local dialect = normalize_dialect(value)
      if dialect then return dialect end
    end
  end
  return nil
end

-- Ignore examples in comments and literal contents when looking for dialect-specific syntax.
local function code_without_literals(text)
  local output = {}
  local i = 1
  local state = 'code'
  while i <= #text do
    local char = text:sub(i, i)
    local next_char = text:sub(i + 1, i + 1)
    if state == 'code' then
      if char == '-' and next_char == '-' then
        state = 'line_comment'
        i = i + 2
      elseif char == '/' and next_char == '*' then
        state = 'block_comment'
        i = i + 2
      elseif char == "'" or char == '"' or char == '`' then
        state = char
        output[#output + 1] = ' '
        i = i + 1
      elseif char == '$' then
        local tag = text:sub(i):match('^(%$[%w_]*%$)')
        if tag then
          output[#output + 1] = tag
          local close = text:find(tag, i + #tag, true)
          i = close and (close + #tag) or (i + #tag)
        else
          output[#output + 1] = char
          i = i + 1
        end
      else
        output[#output + 1] = char
        i = i + 1
      end
    elseif state == 'line_comment' then
      if char == '\n' then
        output[#output + 1] = '\n'
        state = 'code'
      end
      i = i + 1
    elseif state == 'block_comment' then
      if char == '*' and next_char == '/' then
        state = 'code'
        i = i + 2
      else
        if char == '\n' then output[#output + 1] = '\n' end
        i = i + 1
      end
    else
      if char == state then
        if next_char == state then
          i = i + 2
        else
          state = 'code'
          i = i + 1
        end
      else
        if char == '\n' then output[#output + 1] = '\n' end
        i = i + 1
      end
    end
  end
  return table.concat(output):lower()
end

local function line_matches(text, pattern)
  for line in (text .. '\n'):gmatch('(.-)\n') do
    if line:match('^%s*' .. pattern .. '%s*$') then return true end
  end
  return false
end

local function inferred_dialect(lines)
  local code = code_without_literals(table.concat(lines, '\n'))
  local detected = {}

  detected.postgres = code:find('::', 1, true) ~= nil or code:match('%f[%a]language%s+plpgsql%f[%A]') ~= nil or code:match('%f[%a]do%s+%$[%w_]*%$') ~= nil
  detected.mysql = code:find('auto_increment', 1, true) ~= nil or code:find('on duplicate key update', 1, true) ~= nil or line_matches(code, 'delimiter%s+.+')
  detected.sqlite = code:find('without rowid', 1, true) ~= nil or code:find('sqlite_master', 1, true) ~= nil or line_matches(code, 'pragma%s+.+')
  detected.tsql = code:match('%f[%a]declare%s+@[%a_]') ~= nil or code:match('%f[%a]nvarchar%s*%(') ~= nil or line_matches(code, 'go%s*;?')
  detected.oracle = code:match('%f[%a]varchar2%s*%(') ~= nil or code:match('%f[%a]connect%s+by%f[%A]') ~= nil
  detected.bigquery = code:match('%f[%a]safe_cast%s*%(') ~= nil
  detected.snowflake = code:match('%f[%a]flatten%s*%([^)]-=>') ~= nil

  local match
  for dialect, found in pairs(detected) do
    if found then
      -- Conflicting evidence is less safe than the conservative ANSI fallback.
      if match then return nil end
      match = dialect
    end
  end
  return match
end

function Sql.resolve(opts)
  local dialect = normalize_dialect(opts.buffer_dialect)
  if dialect then return dialect, 'buffer' end

  dialect = header_dialect(opts.lines)
  if dialect then return dialect, 'header' end

  dialect = config_dialect(opts.project_config)
  if dialect then return dialect, 'project' end

  dialect = inferred_dialect(opts.lines)
  if dialect then return dialect, 'syntax' end

  return 'ansi', 'fallback'
end

function Sql.resolve_buffer(bufnr, dirname)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  dirname = dirname or (filename ~= '' and vim.fs.dirname(filename) or nil)
  local project_config = dirname and find_upward_file({ dirname = dirname }, { '.sqlfluff', 'sqlfluff.cfg' }) or nil
  local dialect, source = Sql.resolve({
    buffer_dialect = vim.b[bufnr].sql_dialect,
    lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false),
    project_config = project_config and read_file(project_config) or nil,
  })
  return dialect, source, project_config
end

function Sql.setup()
  vim.api.nvim_create_user_command('SqlDialect', function(opts)
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.bo[bufnr].filetype ~= 'sql' then
      vim.notify('SqlDialect is only available in SQL buffers', vim.log.levels.ERROR)
      return
    end

    if opts.bang then
      if opts.args ~= '' then
        vim.notify('SqlDialect! does not accept a dialect', vim.log.levels.ERROR)
        return
      end
      vim.b[bufnr].sql_dialect = nil
      local dialect, source = Sql.resolve_buffer(bufnr)
      vim.notify(('SQL dialect override cleared; effective dialect: %s (%s)'):format(dialect, source))
      return
    end

    if opts.args == '' then
      local dialect, source = Sql.resolve_buffer(bufnr)
      vim.notify(('SQL dialect: %s (%s)'):format(dialect, source))
      return
    end

    local dialect = normalize_dialect(opts.args)
    if not dialect then
      vim.notify(('Unsupported SQL dialect: %s'):format(opts.args), vim.log.levels.ERROR)
      return
    end
    vim.b[bufnr].sql_dialect = dialect
    vim.notify(('SQL dialect set to %s'):format(dialect))
  end, {
    bang = true,
    desc = 'Set the SQLFluff dialect for the current buffer',
    nargs = '?',
    complete = function(arg_lead)
      local prefix = arg_lead:lower()
      local matches = {}
      for _, dialect in ipairs(SUPPORTED_DIALECTS) do
        if dialect:sub(1, #prefix) == prefix then matches[#matches + 1] = dialect end
      end
      return matches
    end,
  })
end

function Sql.formatter(cfg)
  return {
    command = 'sqlfluff',
    args = function(_, ctx)
      local dialect, _, project_config = Sql.resolve_buffer(ctx.buf, ctx.dirname)
      local args = { 'format', '--stdin-filename', '$FILENAME' }
      if not project_config then vim.list_extend(args, { '--config', vim.fn.expand(cfg .. '/sqlfluff.cfg') }) end
      vim.list_extend(args, { '--dialect', dialect, '-' })
      return args
    end,
    stdin = true,
    require_cwd = false,
  }
end

return Sql
