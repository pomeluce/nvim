local colors = require('user.configs.heirline.colors')
local conditions = require('heirline.conditions')

return {
  -- icon
  {
    init = function(self)
      local filename = self.filename
      local extension = vim.fn.fnamemodify(filename, ':e')
      self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
    end,
    provider = function(self)
      return self.icon and (' ' .. self.icon .. ' ')
    end,
    hl = function(self)
      return { fg = self.icon_color }
    end,
  },
  -- name
  {
    -- modified
    hl = function()
      if vim.bo.modified then
        -- use `force` because we need to override the child's hl foreground
        return { fg = colors.cyan, bold = true, force = true }
      end
    end,
    {
      provider = function(self)
        -- see :h filename-modifers
        local filename = vim.fn.fnamemodify(self.filename, ':.')
        if filename == '' then
          return '[No Name]'
        end
        if not conditions.width_percent_below(#filename, 0.25) then
          filename = vim.fn.pathshorten(filename)
        end
        return filename
      end,
      hl = { fg = colors.white },
    },
  },
  -- flag
  {
    {
      condition = function()
        return vim.bo.modified
      end,
      provider = ' [+]',
    },
    {
      condition = function()
        return not vim.bo.modifiable or vim.bo.readonly
      end,
      provider = ' 󰌾',
    },
  },
  -- this means that the statusline is cut here when there's not enough space
  { provider = '%<' },
}
