local G = require('G')
local M = {}

function M.config()
  G.map({
    { 'n', '<leader>rt', '<cmd>lua require("spectre").open()<CR>', { noremap = true, silent = true } },
    { 'v', '<leader>rt', '<esc>:lua require("spectre").open_visual({ select_word=true })<CR>',
      { noremap = true, silent = true } },
  })
end

function M.setup()
  -- do nothing
end

return M
