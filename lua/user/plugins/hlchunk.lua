local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return {
    chunk = {
      style = {
        { fg = '#61A3BA' },
        { fg = '#c21f30' }, -- 这个高亮是用来标志错误的代码块
      },
    },
    indent = {
      chars = { '│' }, -- 更多的字符可以在 https://unicodeplus.com/ 这个网站上找到
      style = {
        '#E06C75',
        '#E5C07B',
        '#61AFEF',
        '#D19A66',
        '#98C379',
        '#C678DD',
        '#56B6C2',
      },
    },
    line_num = {
      enable = true,
      use_treesitter = false,
      style = '#61A3BA',
    },
    blank = {
      enable = false,
    },
  }
end
return M
