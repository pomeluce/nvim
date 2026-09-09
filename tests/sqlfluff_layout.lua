local function format_sql(input, filename)
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
      filename,
      '-',
    }, { stdin = input, text = true })
    :wait()
  assert(result.code == 0, result.stderr ~= '' and result.stderr or result.stdout)
  return result.stdout
end

local function assert_format(name, input, expected)
  local actual = format_sql(input, name .. '.sql')
  assert(actual == expected, ('unexpected %s output:\n%s'):format(name, actual))
end

assert_format(
  'create-table',
  [=[create table akir_menu
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
]=],
  [=[create table akir_menu
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
)

assert_format(
  'compact-clauses',
  [=[comment on
table akir_menu is '菜单表';

select *
from
  akir_menu;
]=],
  [=[comment on table akir_menu is '菜单表';

select *
from akir_menu;
]=]
)

assert_format(
  'complex-query',
  [=[with ranked_menu as (
  select
    menu_id,
    label,
    case
      when disabled then 'disabled'
      else 'enabled'
    end as status,
    row_number() over (
      partition by parent_id
      order by sort
    ) as row_num
  from
    akir_menu
  where
    show = true
)
select
  menu.menu_id,
  menu.label,
  role.role_count
from
  ranked_menu as menu
left join (
  select
    menu_id,
    count(*) as role_count
  from
    akir_role_menu
  group by
    menu_id
) as role
  on
    role.menu_id = menu.menu_id
    and role.role_count > 0
where
  menu.row_num = 1
order by
  menu.menu_id;
]=],
  [=[with ranked_menu as (
  select
    menu_id,
    label,
    case
      when disabled then 'disabled'
      else 'enabled'
    end as status,
    row_number() over (
      partition by parent_id
      order by sort
    )   as row_num
  from akir_menu
  where
    show = true
)

select
  menu.menu_id,
  menu.label,
  role.role_count
from ranked_menu as menu
left join (
  select
    menu_id,
    count(*) as role_count
  from akir_role_menu
  group by
    menu_id
) as role
  on
    role.menu_id = menu.menu_id
    and role.role_count > 0
where
  menu.row_num = 1
order by
  menu.menu_id;
]=]
)

print('sqlfluff layout tests passed')
