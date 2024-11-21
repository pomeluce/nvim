local colors = require('user.configs.heirline.colors')

return {
  provider = function()
    return '  %2(' .. os.date('%H:%M:%S') .. '%) '
  end,
  hl = { fg = colors.light_grey },
}
