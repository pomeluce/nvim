local colors = require('user.configs.heirline.colors')
local utils = require('user.configs.heirline.utils')

return {
  provider = function()
    local msg = vim.lsp.status()
    if #msg == 0 or vim.o.columns < 120 then
      return ''
    end

    local spinners = { '', '󰪞', '󰪟', '󰪠', '󰪢', '󰪣', '󰪤', '󰪥' }
    local ms = vim.loop.hrtime() / 1e6
    local frame = math.floor(ms / 100) % #spinners

    return spinners[frame + 1] .. ' ' .. msg
  end,

  hl = { fg = colors.yellow },

  utils.space(3),
}
