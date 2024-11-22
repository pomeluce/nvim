local colors = require('user.configs.heirline.colors')
local conditions = require('heirline.conditions')

return {
  condition = conditions.is_git_repo,

  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
  end,

  hl = { fg = colors.blue },

  -- git branch name
  {
    provider = function(self)
      return '  %2(' .. self.status_dict.head .. '%) '
    end,
  },
}
