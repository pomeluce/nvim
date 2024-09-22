local colors = require('user.configs.heirline.colors')
local utils = require('user.configs.heirline.utils')

return {
  {
    provider = utils.separators.left,
    hl = { fg = colors.green },
  },
  {
    provider = ' ',
    hl = { fg = colors.black2, bg = colors.green },
  },
  {
    provider = function()
      local cur = vim.fn.line('.')
      local total = vim.fn.line('$')
      if cur == 1 then
        return ' Top '
      elseif cur == total then
        return ' Bot '
      else
        return string.format(' %2d%%%% ', math.floor(cur / total * 100))
      end
    end,
  },
  {
    static = {
      sbar = { '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' },
    },
    provider = function(self)
      local curr_line = vim.api.nvim_win_get_cursor(0)[1]
      local lines = vim.api.nvim_buf_line_count(0)
      local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
      return string.rep(self.sbar[i], 2)
    end,
    hl = { fg = colors.light_grey },
  },
}
