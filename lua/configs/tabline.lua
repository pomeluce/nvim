-- local palette = require('catppuccin.palettes').get_palette('mocha')
local palette = require('mini.base16').config.palette

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
    hl = function(self) return vim.api.nvim_get_current_win() == self.winid and { fg = palette.base0E } or {} end,
  },
  -- buffer
  {
    require('heirline.utils').make_buflist(
      {
        -- filename
        {
          init = function(self) self.filename = vim.api.nvim_buf_get_name(self.bufnr) end,
          hl = function(self) return { fg = self.is_active and palette.base06 or palette.base04 } end,
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
            hl = { fg = palette.base0B },
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
              hl = function(self) return { fg = self.is_active and palette.base08 or palette.base04 } end,
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
        hl = function(self) return { fg = self.is_active and palette.base04 or palette.base06 } end,
      },
      -- 右截断
      {
        provider = '  ',
        hl = function(self) return { fg = self.is_active and palette.base04 or palette.base06 } end,
      }
    ),
    { provider = '%=' },
  },
  -- tab
  {
    condition = function() return #vim.api.nvim_list_tabpages() >= 2 end,
    require('heirline.utils').make_tablist({
      provider = function(self) return '%' .. self.tabnr .. 'T ' .. self.tabnr .. ' %T' end,
      hl = function(self) return self.is_active and { bg = palette.base0E, fg = palette.base00 } or { fg = palette.base04, bg = palette.base01 } end,
      -- 关闭按钮
      {
        condition = function(self) return self.is_active end,
        provider = '󰅙 ',
        on_click = {
          callback = function()
            -- 关闭当前 tab，包括其所有 buffer
            vim.cmd('tabclose')
          end,
          name = 'tabclose_cb',
        },
      },
    }),
  },
}
