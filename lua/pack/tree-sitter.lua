local G = require('G')
local M = {}

function M.config()
  G.map({ { 'n', 'H', ':TSHighlightCapturesUnderCursor<CR>', { noremap = true, silent = true } } })
end

function M.setup()
  require('nvim-treesitter.configs').setup {
    -- 安装全部解析器
    ensure_installed = "all",
    -- 忽略安装的解析器
    ignore_install = { "swift", "phpdoc" },
    --开启高亮
    highlight = {
      enable = true
    },
  }

  -- TODO: 高亮设置
  G.cmd('match Todo /TODO\\(:.*\\)*/')
  -- 注释高亮
  G.cmd('hi @comment guifg = #bdbdbd')
end

return M
