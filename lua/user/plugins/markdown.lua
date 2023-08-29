local M = {}

function M.config()
  -- 要预览的浏览器
  vim.g.mkdp_browser = 'firefox'
  -- makedown 配色文件
  vim.g.mkdp_markdown_css = '~/.config/nvim/colors/github.css'
  -- 页面标题
  vim.g.mkdp_page_title = '${name}'
  -- 预览选项
  vim.g.mkdp_preview_options = { hide_yaml_meta = 1, disable_filename = 1 }
  -- 主题
  -- G.g.mkdp_theme = 'dark'
  -- 围栏标记
  vim.g.vmt_fence_text = 'markdown-toc'
end

function M.setup()
  return {
    glow_path = '', -- will be filled automatically with your glow bin in $PATH, if any
    install_path = vim.fn.stdpath('data') .. '/glow', -- default path for installing glow binary
    border = 'single', -- floating window border config
    style = 'dark', -- filled automatically with your current editor background, you can override using glow json style
    pager = false,
    width = 100,
    height = 100,
    width_ratio = 0.7, -- maximum width of the Glow window compared to the nvim window size (overrides `width`)
    height_ratio = 0.7,
  }
end

return M
