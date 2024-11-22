local colors = require('user.configs.heirline.colors')

return {
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ':e')
    self.icon = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
  end,
  provider = function(self)
    local icon = self.icon and self.icon or ''
    return vim.bo.filetype ~= '' and ' ' .. icon .. ' %2(' .. string.lower(vim.bo.filetype) .. '%) '
  end,
  hl = { fg = colors.vibrant_green },
}
