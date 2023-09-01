local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return {
    options = {
      -- 指定皮肤
      -- https://github.com/nvim-lualine/lualine.nvim/blob/master/THEMES.md
      theme = 'onedark',
      -- 开启图标
      icons_enabled = true,
      -- 分割线
      component_separators = {
        left = '',
        right = '',
      },
      -- https://github.com/ryanoasis/powerline-extra-symbols
      section_separators = {
        left = '',
        right = '',
      },
      -- 启用全局状态栏
      globalstatus = true,
    },
    -- 更改 nvim-tree 外观
    extensions = { 'nvim-tree' },
    sections = {
      lualine_b = {
        -- git branch
        'branch',
        -- git diff
        {
          'diff',
          -- 开启颜色
          colored = true,
          symbols = { added = '+', modified = '~', removed = '-' },
        },
        {
          -- 诊断信息
          'diagnostics',
          -- 诊断来源 coc
          sources = { 'nvim_diagnostic', 'nvim_lsp' },
          -- 诊断级别
          sections = { 'error', 'warn', 'info' },
          symbols = { error = '󰬌 ', warn = '󰬞 ', info = '󰬐 ' },
          -- 开启颜色
          colored = true,
          -- 在插入模式下更新诊断
          update_in_insert = true,
          -- 显示诊断, 即使没有错误
          always_visible = true,
        },
      },
      lualine_c = {
        -- 文件名称
        {
          'filename',
          file_status = true, -- Displays file status (readonly status, modified status)
          newfile_status = true, -- Display new file status (new file means no write after created)
          path = 1, -- 0: Just the filename
          -- 1: Relative path
          -- 2: Absolute path
          -- 3: Absolute path, with tilde as the home directory
          -- 4: Filename and parent dir, with tilde as the home directory

          shorting_target = 40, -- Shortens path to leave 40 spaces in the window
          -- for other components. (terrible name, any suggestions?)
          symbols = {
            modified = '[+]', -- Text to show when the file is modified.
            readonly = '[-]', -- Text to show when the file is non-modifiable or readonly.
            unnamed = '[No Name]', -- Text to show for unnamed buffers.
            newfile = '[New]', -- Text to show for newly created file before first write
          },
        },
      },
      lualine_x = {
        -- 文件大小
        'filesize',
        -- 文件格式
        {
          'fileformat',
          symbols = {
            unix = '', -- e712
            dos = '', -- e70f
            mac = '', -- e711
          },
        },
        -- 显示编码
        'encoding',
        -- 文件类型
        'filetype',
      },
      lualine_y = {
        {
          'datetime',
          -- options: default, us, uk, iso, or your own format string ("%H:%M", etc..)
          style = '%H:%M:%S',
        },
        'progress',
      },
    },
  }
end

return M
