local G = require('G')
local M = {}

function M.config()
  M.on_attach = function(client, bufnr)
    -- 快捷键配置
    G.map({
      -- 跳转到错误
      -- TODO: goto 跳转
      { 'n', 'ge', '<cmd>lua vim.diagnostic.goto_next()<cr>', { noremap = true, silent = true, buffer = bufnr } },
      -- 跳转到定义
      { 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', { noremap = true, silent = true, buffer = bufnr } },
    })
  end
end

function M.setup()
  -- do nothing
end

return M
