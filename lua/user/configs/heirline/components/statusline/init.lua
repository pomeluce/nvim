local utils = require('heirline.utils')
local _utils = require('user.configs.heirline.utils')

return {
  utils.insert(
    {
      init = function(self)
        self.mode = vim.fn.mode(1)
        self.filename = vim.api.nvim_buf_get_name(0)
      end,
      hl = { bg = 'NONE' },
    },
    require('user.configs.heirline.components.statusline.mode'),
    require('user.configs.heirline.components.statusline.git-branch'),
    require('user.configs.heirline.components.statusline.filename'),
    _utils.align,
    require('user.configs.heirline.components.statusline.diagnostics'),
    require('user.configs.heirline.components.statusline.encoding'),
    require('user.configs.heirline.components.statusline.filetype'),
    require('user.configs.heirline.components.statusline.postion'),
    require('user.configs.heirline.components.statusline.cursor')
  ),
}
