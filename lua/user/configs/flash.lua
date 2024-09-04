local M = {}

function M.config()
  -- do noting
end

function M.setup()
  return {
    modes = {
      -- 关闭字符增强
      char = {
        enabled = false,
      },
    },
  }
end
return M
