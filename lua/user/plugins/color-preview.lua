local M = {}

M.config = function()
  -- do nothing
end

M.setup = function()
  return {
    render = 'background',
    virtual_symbol = '■',
    -- name 支持
    enable_named_colors = true,
    -- Tailwind 支持
    enable_tailwind = true,

    ---Set custom colors
    ---Label must be properly escaped with '%' to adhere to `string.gmatch`
    --- :help string.gmatch
    -- custom_colors = {
    --   { label = '%-%-theme%-primary%-color', color = '#0f1219' },
    --   { label = '%-%-theme%-secondary%-color', color = '#5a5d64' },
    -- },
  }
end

return M
