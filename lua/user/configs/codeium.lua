local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return {
    config_path = vim.fn.stdpath('data') .. '/codeium/config.json',
    bin_path = vim.fn.stdpath('data') .. '/codeium/bin',
  }
end

return M
