local function float_width() return math.max(1, math.min(120, vim.o.columns - 4)) end

local function float_height() return math.max(1, math.min(36, vim.o.lines - 6)) end

return {
  float = {
    width = float_width,
    height = float_height,
    border = 'rounded',
  },
}
