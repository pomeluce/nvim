local G = require('G')
local M = {}

function M.config()
    G.g.interestingWordsRandomiseColors = 1
    G.map({
      -- 高亮当前光标下单词
      { 'n', 'ff', ":call InterestingWords('n')<cr>", G.opt },
      -- 取消高亮当前光标下单词
      { 'n', 'FF', ":call UncolorAllWords()<cr>", G.opt },
      -- 单词导航
      { 'n', 'n', ":call WordNavigation('forward')<cr>", G.opt },
      { 'n', 'N', ":call WordNavigation('backward')<cr>", G.opt },
    })
end

function M.setup()
    -- do nothing
end

return M
