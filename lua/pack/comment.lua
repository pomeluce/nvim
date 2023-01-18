local G = require('G')
local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  local ft = require('Comment.ft')
  require('Comment').setup({
    -- N 模式注释快捷键
    toggler = {
      line = '<leader>/',
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
  })
  -- 单独设置注释
  ft.set('java', { '// %s', '/* %s */' })
end

return M
