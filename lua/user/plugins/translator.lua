local M = {}

function M.config()
  -- 目标语言
  vim.g.translator_target_lang = 'zh'
  -- 源语言
  vim.g.translator_source_lang = 'auto'
  -- 翻译引擎
  vim.g.translator_default_engines = { 'google' }
  -- 边框
  vim.g.translator_window_borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' }
end

function M.setup()
  -- do nothing
end

return M
