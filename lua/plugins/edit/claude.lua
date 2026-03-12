vim.pack.add({
  { src = 'https://github.com/coder/claudecode.nvim' },
})

local map = vim.keymap.set

local function select_model()
  local models = require('utils').read_json(os.getenv('HOME') .. '/.claude/models.json') or {}

  local transformed = {}
  for i, m in ipairs(models) do
    local nm = tostring(m.name or '')
    local mdl = tostring(m.model or '')
    table.insert(transformed, { idx = i, source = 1, text = nm, name = mdl })
  end

  Snacks.picker({
    title = 'Toggle Claude Model',
    layout = 'select',
    items = transformed,
    format = function(item)
      local pad = 10
      local label = ('%-' .. pad .. 's'):format(item.text)
      return { { label, 'SnacksPickerLabel' }, { item.name, 'SnacksPickerList' } }
    end,
    confirm = function(picker, item)
      picker:close()
      vim.system({ 'ccs', item.text }, { text = true }, function(res)
        if res.code == 0 then
          vim.notify('Switch to model: ' .. item.text .. '/' .. item.name, vim.log.levels.INFO)
        else
          vim.notify('Switch to model fail: ' .. (res.stderr or ''), vim.log.levels.WARN)
        end
      end)
    end,
  })
end

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('SetupClaude', { clear = true }),
  callback = function()
    require('claudecode').setup({
      terminal_cmd = vim.fn.exepath('claude'),
    })
    -- Claude
    map('n', '<leader>ac', '<cmd>ClaudeCode<cr>', { desc = 'Toggle Claude' })
    map('n', '<leader>af', '<cmd>ClaudeCodeFocus<cr>', { desc = 'Focus Claude' })
    map('n', '<leader>ar', '<cmd>ClaudeCode --resume<cr>', { desc = 'Resume Claude' })
    map('n', '<leader>aC', '<cmd>ClaudeCode --continue<cr>', { desc = 'Continue Claude' })
    -- map('n', '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', { desc = 'Select Claude model' })
    map('n', '<leader>am', select_model, { desc = 'Select Claude model' })
    map('n', '<leader>aq', '<cmd>ClaudeCodeClose<cr>', { desc = 'Close Claude' })
    -- Buffer / File
    map('n', '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', { desc = 'Add current buffer' })
    -- Visual send
    map('v', '<leader>as', '<cmd>ClaudeCodeSend<cr>', { desc = 'Send to Claude' })
    -- Diff management
    map('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', { desc = 'Accept diff' })
    map('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', { desc = 'Deny diff' })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw' },
  callback = function() map('n', '<leader>as', '<cmd>ClaudeCodeTreeAdd<cr>', { desc = 'Add file', buffer = true }) end,
})
