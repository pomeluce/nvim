local utils = require('heirline.utils')
local _utils = require('user.configs.heirline.utils')

-- a nice "x" button to close the buffer
local TablineCloseButton = {
  condition = function(self)
    return not vim.api.nvim_get_option_value('modified', { buf = self.bufnr })
  end,
  { provider = ' ' },
  {
    provider = '',
    hl = { fg = 'gray' },
    on_click = {
      callback = function(_, minwid)
        vim.schedule(function()
          vim.api.nvim_buf_delete(minwid, { force = false })
          vim.cmd.redrawtabline()
        end)
      end,
      minwid = function(self)
        return self.bufnr
      end,
      name = 'heirline_tabline_close_buffer_callback',
    },
  },
}

local offset = require('user.configs.heirline.components.bufferline.offset')
local filename = require('user.configs.heirline.components.bufferline.filename')

return {

  hl = { bg = 'NONE' },

  offset,
  utils.make_buflist(
    { filename, TablineCloseButton, _utils.space(2) },
    { provider = '', hl = { fg = 'gray' } }, -- left truncation, optional (defaults to "<")
    { provider = '', hl = { fg = 'gray' } } -- right trunctation, also optional (defaults to ...... yep, ">")
    -- by the way, open a lot of buffers and try clicking them ;)
  ),
  _utils.align,
}
