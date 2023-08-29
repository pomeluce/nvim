local M = {}

function M.config()
  vim.opt.list = true
end

function M.setup()
  return {
    -- 空行占位符
    space_char_blankline = ' ',
    -- 用 treesitter 判断上下文
    show_current_context = true,
    show_current_context_start = true,
    context_patterns = {
      'class',
      'interface',
      'function',
      'method',
      'struct',
      'enum',
      'element',
      'switch',
      'case',
      '^if',
      '^while',
      '^for',
      '^object',
      '^table',
      'block',
      'arguments',
    },
    -- 竖线样式
    char = '▏',
  }
end

return M
