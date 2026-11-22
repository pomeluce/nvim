local root = vim.fs.dirname(vim.fs.dirname(vim.fs.abspath(debug.getinfo(1, 'S').source:sub(2))))
vim.opt.rtp:prepend(root)
dofile(root .. '/lua/plugins/edit/codex.lua')

require('configs.codex').setup({
  codex_cmd = vim.fn.exepath('sh'),
  codex_args = { '-c', 'printf "0123456789012345678901234567890123456789\\n"; IFS= read -r input' },
})

vim.cmd.CodexFocus()
local sidebar = vim.api.nvim_get_current_win()
local buffer = vim.api.nvim_get_current_buf()
assert(vim.wait(1000, function() return #table.concat(vim.api.nvim_buf_get_lines(buffer, 0, -1, false), '') >= 40 end), 'Codex fixture did not start')
assert(vim.wo[sidebar].winbar == "%#Title#%{get(b:, 'codex_instance', 1)}:  Codex CLI%*", 'Codex terminal winbar title must stay consistent')
assert(vim.b[buffer].codex_instance == 1, 'Codex terminal instance id must start at one')

vim.cmd.stopinsert()
vim.cmd.normal({ bang = true, args = { 'gg$' } })
local editor
for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
  if win ~= sidebar and vim.bo[vim.api.nvim_win_get_buf(win)].buftype == '' then editor = win end
end
assert(editor, 'Codex resize test needs an editor window')
vim.api.nvim_set_current_win(editor)
local initial = vim.api.nvim_win_get_width(sidebar)
vim.api.nvim_win_set_width(sidebar, initial - 10)
vim.api.nvim_win_set_width(sidebar, initial)
vim.api.nvim_exec_autocmds('WinResized', {})
vim.cmd.redraw({ bang = true })

local view = vim.api.nvim_win_call(sidebar, vim.fn.winsaveview)
assert(view.leftcol == 0, 'Codex terminal kept a stale horizontal offset after resizing')
print('Codex resize regression test passed')

vim.fn.jobstop(vim.b[buffer].terminal_job_id)
vim.cmd.qa({ bang = true })
