local Sql = {}

local DIALECT_ALIASES = {
  mssql = 'tsql',
  postgresql = 'postgres',
  sqlserver = 'tsql',
}

local function normalize_dialect(value)
  if type(value) ~= 'string' then return nil end
  local dialect = value:lower():match('^%s*([%a][%w_-]*)%s*$')
  return dialect and (DIALECT_ALIASES[dialect] or dialect) or nil
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

return Sql
