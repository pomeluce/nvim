local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return {
    opts = {
      enable_rename = true,
      enable_close = true,
      enable_close_on_slash = true,
    },
  }
end

return M
