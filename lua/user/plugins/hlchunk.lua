local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return {
    chunk = {
      style = {
        { fg = '#79AC78' },
        { fg = '#c21f30' }, -- 这个高亮是用来标志错误的代码块
      },
      use_treesitter = false,
    },
    indent = {
      -- 更多的字符可以在 https://unicodeplus.com/ 这个网站上找到
      chars = { '│' },
      style = { '#4C5257' },
    },
    line_num = {
      enable = true,
      use_treesitter = false,
      style = '#79AC78',
    },
    blank = {
      enable = false,
    },
  }
end

return M
