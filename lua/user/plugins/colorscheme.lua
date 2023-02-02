local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  -- 配置主题
  local status_ok, one_monokai = pcall(require, "one_monokai")
  if not status_ok then
    vim.notify("one_monokai 没有加载或还没有安装")
    return
  end
  vim.cmd([[ colorscheme one_monokai ]])
  one_monokai.setup({
    transparent = true,
  })
end

return M
