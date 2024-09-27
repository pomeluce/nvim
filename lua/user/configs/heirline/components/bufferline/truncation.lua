local colors = require('user.configs.heirline.colors')

return {
  left = {
    provider = '',
    hl = function(self)
      return { fg = self.is_active and colors.white or colors.light_grey }
    end,
  },
  right = {
    provider = '',
    hl = function(self)
      return { fg = self.is_active and colors.white or colors.light_grey }
    end,
  },
}
