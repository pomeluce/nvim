local utils = require('user.configs.heirline.utils')
local colors = require('user.configs.heirline.colors')
local conditions = require('heirline.conditions')

return {
  {
    provider = function(self)
      return '  %2(' .. utils.modes[self.mode][1] .. '%) '
    end,
    hl = function(self)
      return { bg = utils.mode_hl[utils.modes[self.mode][2]], fg = colors.black2, bold = true }
    end,
  },
  {
    provider = utils.separators.right,
    hl = function(self)
      return { bg = colors.grey_fg, fg = utils.mode_hl[utils.modes[self.mode][2]] }
    end,
  },
  {
    provider = utils.separators.right,
    hl = function()
      return { fg = colors.grey_fg, bg = conditions.is_git_repo() and colors.one_bg2 or colors.statusline_bg }
    end,
  },
}
