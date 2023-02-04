local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  local status, dashboard = pcall(require, "dashboard")
  if status then
    vim.notify("dashboard 没有加载或未安装")
  end
  local setting = {
    theme = 'doom',
    config = {
      -- 设置封面
      header = {
        '                                                              ',
        '                                                              ',
        '                                                              ',
        '                                                              ',
        '                                                              ',
        '                                                              ',
        '    ██╗    ██████╗    ██████╗    ██╗   ██╗   ██╗   ███╗   ███ ',
        '    ██║   ██╔═══██╗   ██╔══██╗   ██║   ██║   ██║   ████╗ ████ ',
        '    ██║   ██║   ██║   ██████╔╝   ██║   ██║   ██║   ██╔████╔██ ',
        '    ██║   ██║   ██║   ██╔══██╗   ╚██╗ ██╔╝   ██║   ██║╚██╔╝██ ',
        ' ████╔╝   ╚██████╔╝   ██║  ██║    ╚████╔╝    ██║   ██║ ╚═╝ ██ ',
        ' ════╝     ╚═════╝    ╚═╝  ╚═╝     ╚═══╝     ╚═╝   ╚═╝     ╚═ ',
        '                                                              ',
        '                                                              ',
        '                   [ Jorvim version 1.0.0 ]                   ',
        '                                                              ',
        '                                                              ',
        '                                                              ',
        '                                                              ',
      },
      center = {
        { icon = ' ',
          icon_hl = 'Title',
          desc = 'Project List                         ',
          desc_hl = 'String',
          key = 'p',
          keymap = 'leader s p',
          key_hl = 'Number',
          action = 'NvimTreeOpen /home/developcode/Web/',
        },
        {
          icon = '⌨ ',
          icon_hl = 'Title',
          desc = 'Keymap Setting',
          desc_hl = 'String',
          key = 'm',
          keymap = 'leader e k',
          key_hl = 'Number',
          action = 'edit $HOME/.config/nvim/lua/user/core/keymap.lua',
        },
        {
          icon = ' ',
          icon_hl = 'Title',
          desc = 'Recently Opend Files',
          desc_hl = 'String',
          key = 'h',
          keymap = 'leader f h',
          key_hl = 'Number',
          action = 'FHistory',
        },
        { icon = ' ',
          icon_hl = 'Title',
          desc = 'Find Files',
          desc_hl = 'String',
          key = 'f',
          keymap = 'leader f f',
          key_hl = 'Number',
          action = 'Files',
        },
        { icon = ' ',
          icon_hl = 'Title',
          desc = 'Open Nvim Setting',
          desc_hl = 'String',
          key = 's',
          keymap = 'leader e s',
          key_hl = 'Number',
          action = 'edit $MYVIMRC',
        },
      },
      -- 底部信息
      footer = {'', ' Jorvim is a nvim config for web developer'}
    }
  }
  ---@diagnostic disable-next-line: redundant-parameter
  dashboard.setup(setting)
end

return M
