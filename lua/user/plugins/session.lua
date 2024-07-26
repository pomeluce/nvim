local M = {}

function M.config()
  vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'
end

function M.setup()
  local user_config = require('user-config')
  return {
    projects = vim.list_extend({}, user_config.projects),
    datapath = vim.fn.stdpath('data'),
    -- 非项目目录加载最后一次会话
    last_session_on_startup = true,
    -- 仪表盘模式, 开启取消自动加载
    dashboard_mode = false,
    -- Timeout in milliseconds before trigger FileType autocmd after session load
    -- to make sure lsp servers are attached to the current buffer.
    -- Set to 0 to disable triggering FileType autocmd
    filetype_autocmd_timeout = 200,
    session_manager_opts = {
      -- 在保存会话之前, 这些文件类型的所有缓冲区都将关闭
      autosave_ignore_filetypes = {
        'gitcommit',
        'gitrebase',
      },
      -- 不会自动保存会话的目录列表
      autosave_ignore_dirs = vim.list_extend({ vim.fn.expand('~'), '/' }, user_config.ignore_session_dir),
    },
  }
end

return M
