local G = require('G')
local M = {}

function M.config()
  G.g.interestingWordsRandomiseColors = 1
  G.map({
    -- 高亮当前光标下单词
    { 'n', 'ff', ":call InterestingWords('n')<cr>", { noremap = true, silent = true } },
    -- 取消高亮当前光标下单词
    { 'n', 'FF', ":call UncolorAllWords()<cr>", { noremap = true, silent = true } },
    -- 单词导航
    { 'n', 'n', ":call WordNavigation('forward')<cr>", { noremap = true, silent = true } },
    { 'n', 'N', ":call WordNavigation('backward')<cr>", { noremap = true, silent = true } },
  })
end

function M.setup()
  -- do nothing
end

return M
