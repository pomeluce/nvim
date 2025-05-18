local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return {
    backends = { 'lsp', 'treesitter', 'markdown', 'asciidoc', 'man' },
    layout = {
      default_direction = 'float',
      width = 0.5,
      max_width = 0.8,
    },
    float = {
      border = require('akirc').ui.borderStyle,
      relative = 'win',
      height = 0.5,
      max_height = 0.9,
    },
    keymaps = {
      ['<esc>'] = 'actions.close',
    },
  }
end

return M
