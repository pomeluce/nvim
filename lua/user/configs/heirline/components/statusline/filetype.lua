return {
  condition = function()
    return vim.bo.filetype ~= ''
  end,
  {
    init = function(self)
      local filename = self.filename
      local extension = vim.fn.fnamemodify(filename, ':e')
      self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
    end,
    provider = function(self)
      local icon = self.icon and self.icon or ''
      return ' ' .. icon
    end,
    hl = function(self)
      return { fg = self.icon_color }
    end,
  },

  {
    provider = function()
      return ' %2(' .. string.lower(vim.bo.filetype) .. '%) '
    end,
  },
}
