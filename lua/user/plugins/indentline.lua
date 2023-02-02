local M = {}

function M.config()
  vim.opt.list = true
  -- 设置行尾换行符
  -- G.opt.listchars:append "eol:↴"
end

function M.setup()
  local status_ok, indent_blankline = pcall(require, "indent_blankline")
  if not status_ok then
    vim.notify("indent_blankline 没有加载或未安装")
    return
  end
  indent_blankline.setup({
    -- 空行占位符
    space_char_blankline = " ",
    -- 用 treesitter 判断上下文
    show_current_context = true,
    show_current_context_start = true,
    context_patterns = {
      "class",
      "interface",
      "function",
      "method",
      "struct",
      "enum",
      "element",
      "switch",
      "case",
      "^if",
      "^while",
      "^for",
      "^object",
      "^table",
      "block",
      "arguments",
    },
    -- 竖线样式
    char = "▏",
  })
end

return M
