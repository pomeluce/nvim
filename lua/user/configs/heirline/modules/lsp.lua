local conditions = require('heirline.conditions')
local utils = require('user.configs.heirline.utils')
local colors = require('user.configs.heirline.colors')

return {
  condition = conditions.lsp_attached,
  update = { 'LspAttach', 'LspDetach' },
  provider = function()
    for _, client in ipairs(vim.lsp.get_clients()) do
      if client.attached_buffers[utils.stbufnr()] then
        return (vim.o.columns > 100 and ' LSP ~ ' .. client.name) or '  LSP'
      end
    end
  end,
  hl = { fg = colors.nord_blue, bold = true },
  utils.space(2),
}
