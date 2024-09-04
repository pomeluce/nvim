local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return {
    win = {
      border = 'rounded', -- none, single, double, shadow
      padding = { 1, 2, 1, 2 }, -- extra window padding [top, right, bottom, left]
    },
    layout = {
      width = { min = 20, max = 50 }, -- min and max width of the columns
      spacing = 3, -- spacing between columns
    },
  }
end

return M
