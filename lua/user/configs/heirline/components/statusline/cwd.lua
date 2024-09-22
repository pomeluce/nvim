local colors = require('user.configs.heirline.colors')
local utils = require('user.configs.heirline.utils')

return {
  {
    provider = utils.separators.left,
    hl = { fg = colors.folder_bg },
  },
  {
    provider = ' ',
    hl = { fg = colors.black2, bg = colors.folder_bg },
  },
  {
    provider = function()
      local name = vim.loop.cwd() or ''
      return ' ' .. (name:match('([^/\\]+)[/\\]*$') or name)
    end,
  },
  utils.space(1),
}
