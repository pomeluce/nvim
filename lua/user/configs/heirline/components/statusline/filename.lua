local colors = require('user.configs.heirline.colors')
local conditions = require('heirline.conditions')

return {
  -- name
  {
    -- modified
    hl = function()
      if vim.bo.modified then
        return { fg = colors.cyan, force = true }
      end
    end,
    {
      provider = function(self)
        -- see :h filename-modifers
        local filename = vim.fn.fnamemodify(self.filename, ':t')
        if filename == '' then
          return ' [No Name]'
        end
        if not conditions.width_percent_below(#filename, 0.25) then
          filename = vim.fn.pathshorten(filename)
        end
        return ' ' .. filename
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
}
