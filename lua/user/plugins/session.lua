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
    log_level = 'error',
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

  -- 判断是否附带 + 开头的参数，如果有则不加载 session, 防止命令被覆盖
  local args = vim.v.argv;
  for _, arg in ipairs(args) do
    if arg:sub(1, 1) == '+' then
      vim.g.auto_session_enabled = false
      break
    end
  end
end

return M
