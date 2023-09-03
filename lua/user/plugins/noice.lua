local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return {
    views = {
      cmdline_popup = {
        position = {
          row = 5,
          col = '50%',
        },
        size = {
          width = 60,
          height = 'auto',
        },
      },
    },
    cmdline = {
      enabled = true,
      view = 'cmdline_popup',
      opts = {},
      format = {
        --[[
          conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
          view: (default is cmdline view)
          opts: any options passed to the view
          icon_hl_group: optional hl_group for the icon
          title: set to anything or empty string to hide
        ]]
        cmdline = { pattern = '^:', icon = '', lang = 'vim' },
        search_down = { kind = 'search', pattern = '^/', icon = ' ', lang = 'regex' },
        search_up = { kind = 'search', pattern = '^%?', icon = ' ', lang = 'regex' },
        filter = { pattern = '^:%s*!', icon = '$', lang = 'bash' },
        lua = { pattern = { '^:%s*lua%s+', '^:%s*lua%s*=%s*', '^:%s*=%s*' }, icon = '', lang = 'lua' },
        help = { pattern = '^:%s*he?l?p?%s+', icon = '󰞋' },
        input = {}, -- Used by input()
      },
    },
    -- NOTE: 如果打开 messages, cmdline 会被自动开启
    messages = {
      enabled = true,
      view = 'notify', -- default view for messages
      view_error = 'notify', -- view for errors
      view_warn = 'notify', -- view for warnings
      view_history = 'messages', -- view for :messages
      view_search = 'virtualtext', -- view for search count messages. Set to `false` to disable
    },
    popupmenu = {
      enabled = true,
      backend = 'cmp',
    },
    notify = { enabled = false, view = 'notify' },
  }
end

return M
