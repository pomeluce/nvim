local utils = require('user.configs.heirline.utils')
local colors = require('user.configs.heirline.colors')

return {
  {
    provider = utils.separators.left,
    hl = function(self)
      return { fg = utils.mode_hl[utils.modes[self.mode][2]] }
    end,
  },
  {
    provider = function()
      local line = vim.fn.line('.')
      local col = vim.fn.charcol('.')
      return string.format('%3d:%-3d', line, col)
    end,
    hl = function(self)
      return { bg = utils.mode_hl[utils.modes[self.mode][2]], fg = colors.black2 }
    end,
  },

  {
    provider = utils.separators.right,
    hl = function(self)
      return { fg = utils.mode_hl[utils.modes[self.mode][2]] }
    end,
  },
}
