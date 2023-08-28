local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return {
    -- session 保存的目录
    dir = vim.fn.stdpath('data') .. '/sessions/',
    -- 何时保存 session
    options = { "buffers", "curdir", "tabpages", "winsize" },
    -- 保存之前调用的函数
    pre_save = nil,
  }
end

return M
