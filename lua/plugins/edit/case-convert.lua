vim.pack.add({
  { src = 'https://github.com/folke/snacks.nvim' },
})

local M = {}

-- 将任意格式文本解析为单词数组
-- 处理: snake_case, kebab-case, camelCase, PascalCase, UPPER_CASE, dot.case
function M.parse_words(text)
  -- 先按分隔符分割
  local words = {}
  for word in text:gmatch('[^_.%- ]+') do
    table.insert(words, word)
  end

  -- 如果只有一个"单词", 可能是 camelCase/PascalCase/UPPER_CASE
  if #words == 1 then
    local word = words[1]
    words = {}

    -- 处理连续大写字母(如 HTTPServer -> HTTP, Server)
    -- 匹配模式: 大写字母序列 或 单个大写+小写序列
    for part in word:gmatch('[A-Z]+[a-z]*|[a-z]+') do
      table.insert(words, part)
    end

    -- 如果没分割出任何单词, 保持原样
    if #words == 0 then words = { text } end
  end

  -- 统一转换为小写
  for i, w in ipairs(words) do
    words[i] = w:lower()
  end

  return words
end

-- 转换函数表
M.converters = {
  ['snake_case'] = function(words) return table.concat(words, '_') end,

  ['kebab-case'] = function(words) return table.concat(words, '-') end,

  ['camelCase'] = function(words)
    local result = words[1] or ''
    for i = 2, #words do
      result = result .. words[i]:sub(1, 1):upper() .. words[i]:sub(2)
    end
    return result
  end,

  ['PascalCase'] = function(words)
    local result = ''
    for _, w in ipairs(words) do
      result = result .. w:sub(1, 1):upper() .. w:sub(2)
    end
    return result
  end,

  ['UPPER_CASE'] = function(words)
    local upper_words = {}
    for _, w in ipairs(words) do
      table.insert(upper_words, w:upper())
    end
    return table.concat(upper_words, '_')
  end,

  ['lowercase'] = function(words) return table.concat(words, '') end,

  ['UPPERCASE'] = function(words) return table.concat(words, ''):upper() end,

  ['dot.case'] = function(words) return table.concat(words, '.') end,

  ['Title Case'] = function(words)
    local titled = {}
    for _, w in ipairs(words) do
      table.insert(titled, w:sub(1, 1):upper() .. w:sub(2))
    end
    return table.concat(titled, ' ')
  end,
}

-- 风格选项列表
M.styles = {
  { text = 'snake_case', example = 'my_variable_name' },
  { text = 'kebab-case', example = 'my-variable-name' },
  { text = 'camelCase', example = 'myVariableName' },
  { text = 'PascalCase', example = 'MyVariableName' },
  { text = 'UPPER_CASE', example = 'MY_VARIABLE_NAME' },
  { text = 'lowercase', example = 'myvariablename' },
  { text = 'UPPERCASE', example = 'MYVARIABLENAME' },
  { text = 'dot.case', example = 'my.variable.name' },
  { text = 'Title Case', example = 'My Variable Name' },
}

-- 转换选中或当前单词
function M.convert(style, text)
  local words = M.parse_words(text)
  return M.converters[style](words)
end

-- 打开 Snacks picker 选择命名风格
function M.pick_style(text, replace_fn)
  Snacks.picker.select(M.styles, {
    prompt = 'Choose Naming Style',
    format_item = function(item) return item.text .. ' → ' .. item.example end,
  }, function(item)
    if not item then return end
    local converted = M.convert(item.text, text)
    replace_fn(converted)
  end)
end

-- Normal 模式: 转换当前单词
function M.convert_word()
  local word = vim.fn.expand('<cword>')
  if word == '' then
    vim.notify('no word found', vim.log.levels.WARN)
    return
  end

  M.pick_style(word, function(converted)
    -- 替换当前单词
    vim.cmd('normal! ciw' .. converted)
  end)
end

-- Visual 模式: 转换选中文本
function M.convert_selection()
  -- 退出 visual 模式并保存选区位置
  vim.cmd('normal! gv')
  local start_pos = vim.fn.getpos('v')
  local end_pos = vim.fn.getpos('.')
  local lines = vim.fn.getregion(start_pos, end_pos)
  local text = table.concat(lines, '\n')

  if text == '' then
    vim.notify('no text selected', vim.log.levels.WARN)
    return
  end

  -- 保存选区用于后续替换
  local saved_start = start_pos
  local saved_end = end_pos

  M.pick_style(text, function(converted)
    -- 恢复选区并替换
    vim.fn.setpos('.', saved_start)
    vim.cmd('normal! v')
    vim.fn.setpos('.', saved_end)
    vim.cmd('normal! c' .. converted)
  end)
end

-- 快捷键绑定
local map = vim.keymap.set

map('n', '<leader>cc', M.convert_word, { desc = 'Convert naming style (word)' })
map('v', '<leader>cc', M.convert_selection, { desc = 'Convert naming style (selection)' })
