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

      -- 新文件
      if filename == '' then
        return '[No Name]'
      end

      local name = vim.fn.fnamemodify(filename, ':t')

      -- 获取所有 buffer
      local buffers = vim.api.nvim_list_bufs()
      for _, buf in ipairs(buffers) do
        local buf_name = vim.api.nvim_buf_get_name(buf)
        if vim.fn.fnamemodify(buf_name, ':t') == name and buf_name ~= filename then
          local input_parts = vim.split(vim.fn.fnamemodify(filename, ':h'), '/')
          local buf_parts = vim.split(vim.fn.fnamemodify(buf_name, ':h'), '/')

          for i = #input_parts, 1, -1 do
            if input_parts[i] ~= buf_parts[#buf_parts + #input_parts - i] then
              return table.concat(input_parts, '/', i, #input_parts) .. '/' .. name
            end
          end
        end
      end
      return name
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
