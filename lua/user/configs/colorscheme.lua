local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return {
    -- transparent_background = true,
    filter = 'machine',
    inc_search = 'background',
    background_clear = {
      'bufferline',
      'float_win',
      'nvim-tree',
      'telescope',
      'toggleterm',
      'which-key',
    },
    override = function()
      return {
        -- unused variable link to comment color
        DiagnosticUnnecessary = { link = 'Comment' },
      }
    end,
  }
end

return M
