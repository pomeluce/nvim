local utils = require('user.configs.heirline.utils')

return {
  provider = function(self)
    return '  %2(' .. utils.modes[self.mode][1] .. '%) '
  end,
  hl = function(self)
    return { fg = utils.mode_hl[utils.modes[self.mode][2]] }
  end,
}
