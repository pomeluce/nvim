local M = {}

function M.DBUI()
  --[[
    laststatus: 移除状态行
    showtabline: 移除标签行
    nonu: 移除行号
    signcolumn: 移除标记列
    nofoldenable: 移除折叠
  ]]
  vim.cmd('set laststatus=0 showtabline=0 nonu signcolumn=no nofoldenable')
  vim.cmd('exec "DBUI"')
end

function M.config()
  -- 连接文件保存位置
  vim.g.db_ui_save_location = '~/.config/dotfiles/nvim/cache/db_config'
  -- 使用 nerd font
  vim.g.db_ui_use_nerd_fonts = 1
  -- 强制回显通知
  vim.g.db_ui_force_echo_notifications = 1
  -- 预定义方案
  vim.g.db_ui_table_helpers = {
    mysql = {
      ['List'] = 'SELECT * from `{schema}`.`{table}` LIMIT 100;',
      ['Indexes'] = 'SHOW INDEXES FROM `{schema}`.`{table}`;',
      ['Table Fields'] = 'DESCRIBE `{schema}`.`{table}`;',
      ['Alter Table'] = 'ALTER TABLE `{schema}`.`{table}` ADD '
    }
  }
  vim.cmd('com! CALLDB lua require("user.plugins.vim-dadbod").DBUI()')
end

function M.setup()
  -- do nothing
end

return M
