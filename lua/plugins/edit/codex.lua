local codex = require('configs.codex')

local commands = {
  Codex = { 'toggle', desc = 'Toggle the Codex terminal sidebar' },
  CodexFocus = { 'focus', desc = 'Focus the Codex terminal' },
  CodexClose = { 'close', desc = 'Hide the Codex terminal' },
  CodexNew = { 'new', desc = 'Start a fresh Codex conversation' },
  CodexResume = { 'resume', desc = 'Open the Codex session picker' },
  CodexContinue = { 'continue', desc = 'Focus Codex or continue the most recent session' },
  CodexAdd = { 'add', nargs = '?', complete = 'file', desc = 'Add a path to the Codex composer' },
  CodexSend = { 'selection', range = true, desc = 'Add the current selection to the Codex composer' },
  CodexTreeAdd = { 'tree', desc = 'Add the file explorer entry to the Codex composer' },
  CodexInterrupt = { 'interrupt', desc = 'Interrupt the active Codex turn' },
  CodexDiff = { 'diff', desc = 'Run the official Codex diff command' },
}

for name, spec in pairs(commands) do
  local action = spec[1]
  vim.api.nvim_create_user_command(name, function(opts) codex[action](opts) end, {
    nargs = spec.nargs,
    complete = spec.complete,
    range = spec.range,
    desc = spec.desc,
  })
end

codex.setup({
  codex_cmd = vim.fn.exepath('codex') ~= '' and vim.fn.exepath('codex') or 'codex',
  split_width_percentage = 0.40,
})

local map = vim.keymap.set
map('n', '<leader>xc', '<cmd>Codex<cr>', { desc = 'Toggle Codex' })
map('n', '<leader>xf', '<cmd>CodexFocus<cr>', { desc = 'Focus Codex' })
map('n', '<leader>xr', '<cmd>CodexResume<cr>', { desc = 'Resume Codex' })
map('n', '<leader>xC', '<cmd>CodexContinue<cr>', { desc = 'Continue Codex' })
map('n', '<leader>xq', '<cmd>CodexClose<cr>', { desc = 'Hide Codex' })
map('n', '<leader>xb', '<cmd>CodexAdd %<cr>', { desc = 'Add current file to Codex' })
map('x', '<leader>xs', '<cmd>CodexSend<cr>', { desc = 'Add selection to Codex' })
map('n', '<leader>xi', '<cmd>CodexInterrupt<cr>', { desc = 'Interrupt Codex' })
map('n', '<leader>xd', '<cmd>CodexDiff<cr>', { desc = 'Open Codex diff' })

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('CodexExplorerMappings', { clear = true }),
  pattern = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw' },
  callback = function(event) map('n', '<leader>xs', '<cmd>CodexTreeAdd<cr>', { buffer = event.buf, desc = 'Add file to Codex' }) end,
})
