local colors = require('user.configs.heirline.colors')

return {
  provider = function()
    return vim.bo.filetype ~= '' and ' 󰈔 %2(' .. string.lower(vim.bo.filetype) .. '%) '
  end,
  hl = { fg = colors.cyan },
}
