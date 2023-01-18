local G = require('G')
local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  -- lualine 配置
  require('lualine').setup({
    options = {
      -- 指定皮肤
      -- https://github.com/nvim-lualine/lualine.nvim/blob/master/THEMES.md
      theme = "onedark",
      -- 开启图标
      icons_enabled = true,
      -- 分割线
      component_separators = {
        left = "",
        right = "",
      },
      -- https://github.com/ryanoasis/powerline-extra-symbols
      section_separators = {
        left = "",
        right = ""
      },
      -- 启用全局状态栏
      globalstatus = true,
    },
    -- 更改 nvim-tree 外观
    extensions = { "nvim-tree" },
    sections = {
      lualine_b = {
        -- git branch
        'branch',
        -- git diff
        {
          'diff',
          -- 开启颜色
          colored = true,
        },
        {
          -- 诊断信息
          'diagnostics',
          -- 诊断来源 coc
          sources = { 'nvim_diagnostic', 'coc' },
          -- 诊断级别
          sections = { 'error', 'warn', 'info' },
          symbols = { error = 'E', warn = 'W', info = 'I' },
          -- 开启颜色
          colored = true,
          -- 在插入模式下更新诊断
          update_in_insert = true,
          -- 显示诊断, 即使没有错误
          always_visible = true,
        }
      },
      lualine_c = {
        -- 文件名称
        "filename",
        -- lsp 文件进度百分比
        { "lsp_progress", spinner_symbols = { " ", " ", " ", " ", " ", " " }, },
      },
      lualine_x = {
        -- 文件大小
        "filesize",
        -- 文件格式
        {
          "fileformat",
          symbols = {
            unix = '', -- e712
            dos = '', -- e70f
            mac = '', -- e711
          },
        },
        -- 显示编码
        "encoding",
        -- 文件类型
        "filetype",
      },
    },
  })
end

return M
