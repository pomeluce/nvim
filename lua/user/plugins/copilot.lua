local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return {
    suggestion = { enabled = false },
    panel = { enabled = false },
  }
end

return M
