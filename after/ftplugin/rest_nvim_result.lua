vim.keymap.set('n', 'q', '<Cmd>close<CR>', { buffer = true, desc = 'Close HTTP response panel' })

if vim.b.rest_response_markers_hidden then return end
vim.b.rest_response_markers_hidden = true

local namespace = vim.api.nvim_create_namespace('rest_response_markers')
local buffer = vim.api.nvim_get_current_buf()

local function hide_markers()
  vim.api.nvim_buf_clear_namespace(buffer, namespace, 0, -1)
  local count = vim.api.nvim_buf_line_count(buffer)
  -- The renderer places its delimiters immediately before and after the body.
  for _, row in ipairs({ 4, count - 1 }) do
    if row < count then
      local line = vim.api.nvim_buf_get_lines(buffer, row, row + 1, false)[1]
      if (row == 4 and line:match('^# @_RES')) or (row == count - 1 and line == '# @_END') then
        vim.api.nvim_buf_set_extmark(buffer, namespace, row, 0, { end_row = row, end_col = #line, conceal_lines = '' })
      end
    end
  end
end

vim.api.nvim_buf_attach(buffer, false, {
  on_lines = hide_markers,
  -- :quit unloads the pane buffer and detaches this listener.
  on_detach = function() vim.b[buffer].rest_response_markers_hidden = nil end,
})
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = vim.api.nvim_create_augroup('RestResponseMarkers' .. buffer, { clear = true }),
  buffer = buffer,
  callback = function()
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = 'nvic'
  end,
})
hide_markers()
