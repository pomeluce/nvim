local colors = require('user.configs.heirline.colors')
local conditions = require('heirline.conditions')

return {
  condition = conditions.is_git_repo,

  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
  end,

  hl = { fg = colors.dark_purple },

  -- git branch name
  {
    provider = function(self)
      local added_count = self.status_dict.added or 0
      local added = added_count > 0 and ('  ' .. added_count) or ''
      local changed_count = self.status_dict.changed or 0
      local changed = changed_count > 0 and ('  ' .. changed_count) or ''
      local removed_count = self.status_dict.removed or 0
      local removed = removed_count > 0 and ('  ' .. removed_count) or ''
      return ' %2(' .. added .. changed .. removed .. '%) '
    end,
  },
}
