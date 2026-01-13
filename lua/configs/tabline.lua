local palette = require('catppuccin.palettes').get_palette('mocha')

return {
  {
    condition = function(self)
      local win = vim.api.nvim_tabpage_list_wins(0)[1]
      local bufnr = vim.api.nvim_win_get_buf(win)
      self.winid = win
      if vim.bo[bufnr].filetype == 'NvimTree' then
        self.title = 'FileBrowser'
        return true
      end
    end,
    provider = function(self)
      local title = self.title
      local width = vim.api.nvim_win_get_width(self.winid)
      local pad = math.ceil(width - #title)
      return '   ' .. title .. string.rep(' ', pad - 2)
    end,
    hl = function(self) return vim.api.nvim_get_current_win() == self.winid and { fg = palette.blue } or {} end,
  },
  -- buffer
  {
    require('heirline.utils').make_buflist(
      {
        -- filename
        {
          init = function(self) self.filename = vim.api.nvim_buf_get_name(self.bufnr) end,
          hl = function(self) return { fg = self.is_active and palette.overlay2 or palette.overlay0 } end,
          on_click = {
            callback = function(_, minwid, _, button)
              if button == 'm' then
                vim.schedule(function() vim.api.nvim_buf_delete(minwid, { force = false }) end)
              else
                vim.api.nvim_win_set_buf(0, minwid)
              end
            end,
            minwid = function(self) return self.bufnr end,
            name = 'tabline_cb',
          },
          -- space
          { provider = string.rep(' ', 2) },
          -- icon
          {
            init = function(self)
              local name = vim.fn.fnamemodify(self.filename, ':t')
              local micons_present, micons = pcall(require, 'mini.icons')
              if micons_present then
                local ft_icon, ft_icon_hl = micons.get('file', name)
                self.icon = (ft_icon ~= nil and ft_icon) or '󰈚'
                self.icon_hl = (ft_icon_hl ~= nil and ft_icon_hl) or 'Normal'
              end
            end,
            provider = function(self) return self.icon and (' ' .. self.icon .. ' ') end,
            hl = function(self) return { fg = vim.api.nvim_get_hl(0, { name = self.icon_hl }).fg } end,
          },
          -- name
          {
            provider = function(self)
              local filename = self.filename
              if filename == '' then return 'No Name' end
              local name = vim.fn.fnamemodify(filename, ':t')
              local buffers = vim.api.nvim_list_bufs()
              for _, buf in ipairs(buffers) do
                local buf_name = vim.api.nvim_buf_get_name(buf)
                local is_load = vim.api.nvim_buf_is_loaded(buf)
                if vim.fn.fnamemodify(buf_name, ':t') == name and buf_name ~= filename and is_load then
                  local input_parts = vim.split(vim.fn.fnamemodify(filename, ':h'), '/')
                  local buf_parts = vim.split(vim.fn.fnamemodify(buf_name, ':h'), '/')
                  for i = #input_parts, 1, -1 do
                    if input_parts[i] ~= buf_parts[#buf_parts + #input_parts - i] then return table.concat(input_parts, '/', i, #input_parts) .. '/' .. name end
                  end
                end
              end
              return name
            end,
            hl = function(self) return { bold = self.is_active or self.is_visible } end,
          },
          -- modify
          {
            condition = function(self) return vim.api.nvim_get_option_value('modified', { buf = self.bufnr }) end,
            provider = ' ',
            hl = { fg = palette.green },
          },
        },
        -- close
        {
          -- space
          { provider = string.rep(' ', 1) },
          {
            condition = function(self) return not vim.api.nvim_get_option_value('modified', { buf = self.bufnr }) end,
            { provider = string.rep(' ', 1) },
            {
              provider = '',
              hl = function(self) return { fg = self.is_active and palette.red or palette.overlay0 } end,
              on_click = {
                callback = function(_, minwid)
                  vim.schedule(function()
                    vim.api.nvim_buf_delete(minwid, { force = false })
                    vim.cmd.redrawtabline()
                  end)
                end,
                minwid = function(self) return self.bufnr end,
                name = 'bufclose_cb',
              },
            },
          },
        },
      },
      -- 左截断
      {
        provider = '  ',
        hl = function(self) return { fg = self.is_active and palette.overlay0 or palette.overlay2 } end,
      },
      -- 右截断
      {
        provider = '  ',
        hl = function(self) return { fg = self.is_active and palette.overlay0 or palette.overlay2 } end,
      }
    ),
    { provider = '%=' },
  },
  -- tab
  {
    condition = function() return #vim.api.nvim_list_tabpages() >= 2 end,
    require('heirline.utils').make_tablist({
      provider = function(self) return '%' .. self.tabnr .. 'T ' .. self.tabnr .. ' %T' end,
      hl = function(self) return self.is_active and { bg = palette.maroon, fg = palette.crust } or { fg = palette.overlay0, bg = palette.surface0 } end,
      -- 关闭按钮
      {
        condition = function(self) return self.is_active end,
        provider = '󰅙 ',
        on_click = {
          callback = function()
            -- 获取当前 tab 页的所有 buffer
            local buffers = vim.api.nvim_list_bufs()
            for _, buf in ipairs(buffers) do
              -- 确保 buffer 是在当前 tab 中的, 并且是有效 buffer
              if vim.api.nvim_buf_is_loaded(buf) and vim.fn.bufwinnr(buf) ~= -1 then
                -- 关闭 buffer (不保存更改)
                vim.cmd('bdelete! ' .. buf)
              end
            end
          end,
          name = 'tabclose_cb',
        },
      },
    }),
  },
}
