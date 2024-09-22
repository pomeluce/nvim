local colors = require('user.configs.heirline.colors')
local utils = require('user.configs.heirline.utils')

return {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(self.bufnr)
  end,
  hl = function(self)
    return { fg = self.is_active and colors.white or colors.light_grey }
  end,
  on_click = {
    callback = function(_, minwid, _, button)
      if button == 'm' then -- close on mouse middle click
        vim.schedule(function()
          vim.api.nvim_buf_delete(minwid, { force = false })
        end)
      else
        vim.api.nvim_win_set_buf(0, minwid)
      end
    end,
    minwid = function(self)
      return self.bufnr
    end,
    name = 'heirline_tabline_buffer_callback',
  },

  -- icon
  utils.file_icon,

  -- name
  {
    provider = function(self)
      local filename = self.filename
      return (filename == '' and '[No Name]' or vim.fn.fnamemodify(filename, ':t'))
    end,
    hl = function(self)
      return { bold = self.is_active or self.is_visible }
    end,
  },

  -- flag
  {
    {
      condition = function(self)
        return vim.api.nvim_get_option_value('modified', { buf = self.bufnr })
      end,
      provider = ' ',
      hl = { fg = colors.green },
    },
  },
}
