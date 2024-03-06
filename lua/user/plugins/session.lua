local M = {}

function M.config()
  vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'
end

function M.setup()
  return {
    log_level = 'error',
    -- 忽略的目录
    auto_session_suppress_dirs = vim.list_extend({ '~/', '/' }, require('user-config').ignore_session_dir),
    -- session 保存的目录
    auto_session_root_dir = vim.fn.stdpath('data') .. '/sessions/',
    auto_session_enable_last_session = false,
    auto_session_enabled = true,
    auto_save_enabled = false,
    auto_restore_enabled = true,
    auto_session_use_git_branch = nil,
    -- the configs below are lua only
    bypass_session_save_file_types = nil,
  }
end

return M
