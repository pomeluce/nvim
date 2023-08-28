local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return {
    filter_rules = {
      -- 包含当前窗口
      include_current_win = true,
      -- 窗口排除列表
      bo = {
        filetype = { "fidget", 'NvimTree' }
      }
    },
    prompt_message = 'Pick window: ',
    highlights = {
      statusline = {
        focused = {
          fg = '#ededed',
          bg = '#e35e4f',
          bold = true,
        },
        unfocused = {
          fg = '#ededed',
          bg = '#3b5bdb',
          bold = true,
        },
      },
      winbar = {
        focused = {
          fg = '#ededed',
          bg = '#e35e4f',
          bold = true,
        },
        unfocused = {
          fg = '#ededed',
          bg = '#3b5bdb',
          bold = true,
        },
      },
    },
  }
end

return M
