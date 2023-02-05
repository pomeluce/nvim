local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  local status_ok, lspsaga = pcall(require, "lspsaga")
  if not status_ok then
    vim.notify('lspsaga 没有加载或未安装')
    return
  end

  local setting = {
    ui = {
      -- 主题
      theme = "round",
      -- 圆角边框
      border = "rounded",
      winblend = 0,
      expand = "",
      collapse = "",
      preview = " ",
      code_action = "💡",
      diagnostic = "🐞",
      incoming = " ",
      outgoing = " ",
      hover = ' ',
      kind = {},
    },
    -- 顶栏 winbar 设置
    symbol_in_winbar = {
      enable = false,
      separator = " ",
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
        quit = "q",
        exec = "<tab>",
      },
    },
  }

  -- 加载 lspsaga
  ---@diagnostic disable-next-line: redundant-parameter
  lspsaga.setup(setting)
end

return M
