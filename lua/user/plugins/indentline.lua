local M = {}

function M.config()
  vim.opt.list = true
end

function M.setup()
  return {
    indent = {
      -- 竖线样式
      char = '▏',
    },
    -- 用 treesitter 判断上下文
    scope = {
      enabled = true,
      show_start = true,
      highlight = {
        'RainbowRed',
        'RainbowYellow',
        'RainbowBlue',
        'RainbowOrange',
        'RainbowGreen',
        'RainbowViolet',
        'RainbowCyan',
      },
    },
  }
end

return M
