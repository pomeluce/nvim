local colors = require('user.configs.heirline.colors')

return {
  provider = function()
    local cur = vim.fn.line('.')
    local total = vim.fn.line('$')
    if cur == 1 then
      return '  %2(Top %)'
    elseif cur == total then
      return '  %2(Bot %)'
    else
      return '  %2(' .. string.format('%2d%%%% ', math.floor(cur / total * 100)) .. '%)'
    end
  end,
  hl = { fg = colors.yellow },
}
