local M = {}

local match_id = nil

function M.highlight_word()
  local word = vim.fn.expand('<cword>')
  if word == '' then return end

  -- 清掉旧的
  if match_id then
    pcall(vim.fn.matchdelete, match_id)
    match_id = nil
  end

  -- \V 非魔法, 避免特殊字符
  local pat = ([[\V\<%s\>]]):format(vim.fn.escape(word, [[\]]))
  match_id = vim.fn.matchadd('LspReferenceText', pat, 10)
end

function M.clear_word()
  if match_id then
    pcall(vim.fn.matchdelete, match_id)
    match_id = nil
  end
end

return M
