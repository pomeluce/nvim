local colors = require('user.configs.heirline.colors')
local utils = require('user.configs.heirline.utils')

return {
  provider = function()
    local fmt = vim.bo.fileformat
    -- :h 'enc'
    local enc = (vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc
    return ' ' .. utils.fmt[fmt] .. ' %2(' .. enc .. '%) '
  end,
  hl = { fg = colors.orange },
}
