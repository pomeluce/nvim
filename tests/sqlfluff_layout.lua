local input = [=[create table akir_menu
(
  menu_id bigint primary key not null,
  code varchar(50) unique not null,
  label varchar(50) unique not null,
  sort int not null,
  show boolean not null default true,
  disabled boolean not null default false,
  parent_id bigint,
  target varchar(20),
  create_by varchar(20),
  create_time timestamp with time zone,
  update_by varchar(20),
  update_time timestamp with time zone,
  remark text
);
]=]

local expected = [=[create table akir_menu
(
  menu_id     bigint      primary key not null,
  code        varchar(50) unique      not null,
  label       varchar(50) unique      not null,
  sort        int         not null,
  show        boolean     not null    default true,
  disabled    boolean     not null    default false,
  parent_id   bigint,
  target      varchar(20),
  create_by   varchar(20),
  create_time timestamp with time zone,
  update_by   varchar(20),
  update_time timestamp with time zone,
  remark      text
);
]=]

local result = vim
  .system({
    'sqlfluff',
    'format',
    '--disable-progress-bar',
    '--config',
    'lua/configs/fmt/sqlfluff.cfg',
    '--dialect',
    'postgres',
    '--stdin-filename',
    'akir_menu.sql',
    '-',
  }, { stdin = input, text = true })
  :wait()

assert(result.code == 0, result.stderr ~= '' and result.stderr or result.stdout)
assert(result.stdout == expected, ('unexpected SQLFluff output:\n%s'):format(result.stdout))

print('sqlfluff layout tests passed')
