local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return {
    ui = {
      -- 主题
      theme = 'round',
      -- 圆角边框
      border = require('akirc').ui.borderStyle,
      -- 是否使用 nvim-web-devicons
      devicon = true,
      -- 是否显示标题
      title = true,
      winblend = 0,
      -- 展开图标
      expand = '',
      -- 折叠图标
      collapse = '',
      -- 预览图标
      preview = '',
      -- 代码操作图标
      code_action = '󰌵',
      -- 操作修复图标
      actionfix = '',
      -- 诊断图标
      diagnostic = '󰃤',
      -- 实现图标
      imp_sign = '󰳛',
      -- 悬浮图标
      hover = ' ',
      kind = {},
    },
    -- 顶栏 winbar 设置
    symbol_in_winbar = {
      enable = false,
      separator = ' ',
      hide_keyword = true,
      show_file = true,
      folder_level = 2,
      respect_root = true,
      -- 展示颜色
      color_mode = true,
    },
    code_action = {
      num_shortcut = true,
      -- 不显示服务来源
      show_server_name = false,
      keys = {
        -- keymap
        quit = 'q',
        exec = '<tab>',
      },
    },
    rename = {
      keymap = {
        quit = 'q',
      },
    },
  }
end

return M
