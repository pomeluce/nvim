local conditions = require('heirline.conditions')
local utils = require('user.configs.heirline.utils')
local colors = require('user.configs.heirline.colors')

return {
  condition = conditions.lsp_attached,
  update = { 'LspAttach', 'LspDetach' },
  provider = function()
    return ' LSP ~ ' .. string.lower(vim.bo.filetype)
  end,
  hl = { fg = colors.nord_blue, bold = true },
  utils.space(2),
}
