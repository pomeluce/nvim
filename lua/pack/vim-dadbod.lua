local G = require('G')
local M = {}

function DBUI()
  --[[
    laststatus: 移除状态行
    showtabline: 移除标签行
    nonu: 移除行号
    signcolumn: 移除标记列
    nofoldenable: 移除折叠
  ]]
  G.cmd('set laststatus=0 showtabline=0 nonu signcolumn=no nofoldenable')
  G.cmd('exec "DBUI"')
end

function M.config()
  -- 连接文件保存位置
  G.g.db_ui_save_location = '~/Downloads'
  -- 使用 nerd font
  G.g.db_ui_use_nerd_fonts = 1
  -- 强制回显通知
  G.g.db_ui_force_echo_notifications = 1
  -- 预定义方案
  G.g.db_ui_table_helpers = {
    mysql = {
      ['List'] = 'SELECT * from `{schema}`.`{table}` LIMIT 100;',
      ['Indexes'] = 'SHOW INDEXES FROM `{schema}`.`{table}`;',
      ['Table Fields'] = 'DESCRIBE `{schema}`.`{table}`;',
      ['Alter Table'] = 'ALTER TABLE `{schema}`.`{table}` ADD '
    }
  }
  G.cmd('com! CALLDB call v:lua.DBUI()')
end

function M.setup()
  -- do nothing
end

return M
