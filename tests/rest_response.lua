vim.opt.runtimepath:append(vim.fn.getcwd() .. '/after')
vim.cmd('filetype plugin on')

local original = vim.api.nvim_get_current_buf()
local response = vim.api.nvim_create_buf(false, false)
vim.api.nvim_buf_set_name(response, 'rest_nvim_result#Response')
local namespace = vim.api.nvim_create_namespace('rest_response_markers')

local function render(body)
  local lines = { '### Test', 'GET http://localhost/test', 'HTTP/1.1 200 OK', '', '# @_RES' }
  vim.list_extend(lines, body)
  table.insert(lines, '# @_END')
  vim.bo[response].modifiable = true
  vim.api.nvim_buf_set_lines(response, 0, -1, false, lines)
  vim.bo[response].modifiable = false
  vim.bo[response].modified = false
end

local function open()
  if not vim.api.nvim_buf_is_loaded(response) then
    vim.fn.bufload(response)
    vim.bo[response].filetype = 'rest_nvim_result'
  end
  vim.cmd('split')
  vim.api.nvim_win_set_buf(0, response)
end

local function check_markers()
  local marks = vim.api.nvim_buf_get_extmarks(response, namespace, 0, -1, { details = true })
  assert(#marks == 2, 'both renderer markers must be hidden')
  assert(marks[1][2] == 4, 'start marker conceal must follow the rendered start marker')
  assert(marks[2][2] == vim.api.nvim_buf_line_count(response) - 1, 'end marker conceal must follow the rendered end marker')
  for _, mark in ipairs(marks) do
    assert(mark[4].conceal_lines == '', 'marker lines must be concealed')
  end
  assert(vim.wo.conceallevel == 2)
  assert(vim.wo.concealcursor == 'nvic')
end

vim.bo[response].filetype = 'rest_nvim_result'
render({ 'first response' })
open()
check_markers()

-- :quit unloads this unlisted buffer; :close keeps it loaded.
for _, close in ipairs({ 'quit!', 'q', 'quit!', 'q' }) do
  if close == 'q' then
    vim.api.nvim_feedkeys('q', 'xt', false)
  else
    vim.cmd(close)
    assert(not vim.api.nvim_buf_is_loaded(response), 'exercise buffer unload, not just window close')
  end
  assert(vim.api.nvim_get_current_buf() == original, 'closing the panel must preserve the request buffer')
  assert(vim.fn.maparg('q', 'n') == '', 'response mapping must stay buffer-local')
  open()
  render({ 'second response', '# @_RES', '# @_END', 'last body line' })
  check_markers()
  render({ 'updated response' })
  check_markers()
end

print('rest response tests passed')
