local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return {
    indent = { char = '│', highlight = 'IblChar' },
    scope = { char = '│', highlight = 'IblScopeChar' },
  }
end

return M
