local colors = require('user.configs.heirline.colors')
local utils = require('user.configs.heirline.utils')

return {
  {
    provider = utils.separators.left,
    hl = function(self)
      return { fg = utils.mode_hl[utils.modes[self.mode][2]] }
    end,
  },
  {
    provider = function(self)
      return ' %2(' .. utils.modes[self.mode][1] .. '%)'
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
