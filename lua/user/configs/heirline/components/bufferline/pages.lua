local colors = require('user.configs.heirline.colors')
local utils = require('user.configs.heirline.utils')

return {
  {
    -- only show this component if there's 2 or more tabpages
    condition = function()
      return #vim.api.nvim_list_tabpages() >= 2
    end,
    {
      provider = '  ',
      hl = { bg = colors.grey },
      on_click = {
        callback = function()
          vim.cmd('tabnew')
        end,
        name = 'heirline_tabline_add_tab_callback',
      },
    },
    { provider = ' TABS ', hl = { bg = colors.white, fg = colors.black2 } },
    require('heirline.utils').make_tablist {
      provider = function(self)
        return '%' .. self.tabnr .. 'T ' .. self.tabnr .. ' %T'
      end,
      hl = function(self)
        if self.is_active then
          return { bg = colors.nord_blue, fg = colors.black2 }
        else
          return { bg = colors.grey }
        end
      end,

      -- 关闭按钮
      {
        condition = function(self)
          return self.is_active
        end,
        provider = '󰅙 ',
        on_click = {
          callback = utils.close_current_tab_buffer,
          name = 'heirline_tabline_close_tab_callback',
        },
      },
    },
    {
      provider = '%999X  %X',
      hl = { bg = colors.red, fg = colors.black2 },
    },
  },
}
