local G = require('G')
local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  -- 配置主题
  G.cmd([[ colorscheme one_monokai ]])
  require('one_monokai').setup({
    transparent = true,
    colors = {
      gray = '#5c6370',
    }
  })
end

return M
