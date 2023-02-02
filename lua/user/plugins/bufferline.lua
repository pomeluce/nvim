local M = {}

function M.config()
  -- 开启鼠标悬停
  vim.cmd([[ set mousemoveevent ]])
  -- G.opt.termguicolors = true
end

function M.setup()
  -- bufferline 配置
  local status_ok, bufferline = pcall(require, "bufferline")
  if not status_ok then
    vim.notify("bufferline 没有加载或未安装")
    return
  end
  ---@diagnostic disable-next-line: redundant-parameter
  bufferline.setup({
    options = {
      -- 不显示关闭按钮
      show_buffer_close_icons = false,
      -- 使用 nvim_lsp 进行代码检查
      diagnostics = 'nvim_lsp',
      -- 设置分隔符
      separator_style = { '', '' },
      -- 设置鼠标悬停显示关闭按钮
      hover = {
        enabled = true,
        delay = 70,
        reveal = { 'close' }
      },
      -- 设置当前文件下划线
      indicator = {
        -- icon = '', -- this should be omitted if indicator style is not 'icon'
        style = 'none',
      },
    }
  })
end

return M
