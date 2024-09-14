local colors = require('user.configs.heirline.colors')
local utils = require('user.configs.heirline.utils')

return {
  provider = function()
    local fmt = vim.bo.fileformat
    -- :h 'enc'
    return utils.fmt[fmt] .. ' ' .. ((vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc)
  end,
  hl = { fg = colors.sun },

  utils.space(2),
}
