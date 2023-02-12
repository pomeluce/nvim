local M = {}

function M.config()
  vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal'
end

function M.setup()
  local status_ok, session = pcall(require, 'auto-session')
  if not status_ok then
    vim.notify('auto-session 没有加载或未安装')
    return
  end

  session.setup {
    log_level = 'info',
    -- 忽略的目录
    auto_session_suppress_dirs = { '~/', '~/Downloads', '/' },
    -- session 保存的目录
    auto_session_root_dir = vim.fn.stdpath('data') .. '/sessions/',
    auto_session_enable_last_session = false,
    auto_session_enabled = true,
    auto_save_enabled = nil,
    auto_restore_enabled = nil,
    auto_session_use_git_branch = nil,
    -- the configs below are lua only
    bypass_session_save_file_types = nil,
  }
end

return M
