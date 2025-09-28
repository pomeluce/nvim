local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return {
    comment = function()
      require('Comment').setup {
        -- N 模式注释快捷键
        toggler = {
          line = '<leader>/',
          block = '<leader><leader>/',
        },
        -- V 模式注释快捷键
        opleader = {
          line = '<leader>/',
          block = '<leader><leader>/',
        },
        -- 启用快捷键
        mappings = {
          basic = true,
          extra = false,
        },
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      }
      local ft = require('Comment.ft')
      -- 单独设置注释
      ft.set('java', { '// %s', '/* %s */' })
      ft.set('ini', { '; %s' })
    end,

    neogen = {
      enabled = true,
      input_after_comment = true,
    },
  }
end

return M
