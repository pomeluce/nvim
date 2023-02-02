local M = {}

function M.config()
  --do nothing
end

function M.setup()
  local status_ok, symbols_outline = pcall(require, "symbols-outline")
  if not status_ok then
    vim.notify("symbols-outline.nvim 没有加载或未安装")
    return
  end
  symbols_outline.setup()
end

return M
