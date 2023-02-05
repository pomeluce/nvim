local M = {}

function M.config()
  vim.g.user_emmet_mode = 'a'
  -- 设置快捷键
  vim.g.user_emmet_leader_key = '<leader><tab>'
end

function M.setup()
  -- do nothing
end

return M
