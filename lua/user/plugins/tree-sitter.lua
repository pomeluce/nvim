local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  local status_ok, treesitter = pcall(require, "nvim-treesitter.configs")
  if not status_ok then
    vim.notify("treesitter 没有加载或者未安装")
    return
  end

  treesitter.setup({
    -- 安装全部解析器
    ensure_installed = "all",
    -- 忽略安装的解析器
    ignore_install = { "swift", "phpdoc" },
    --开启高亮
    highlight = {
      enable = true
    },
  })

  -- TODO: 高亮设置
  vim.cmd('match Todo /TODO\\(:.*\\)*/')
  -- 注释高亮
  vim.cmd('hi @comment guifg = #bdbdbd')
end

return M
