local M = {}

function M.config()
  -- 要预览的浏览器
  vim.g.mkdp_browser = 'firefox'
  -- makedown 配色文件
  vim.g.mkdp_markdown_css = '~/.config/nvim/colors/markdown.css'
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
  -- do nothing
end

return M
