local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  -- 配置主题
  return {
    transparent_background = true,
    -- devicons = true,
    filter = 'machine',
    inc_search = 'background',
    background_clear = {
      'float_win',
      'nvim-tree',
      'telescope',
      'toggleterm',
      'which-key',
    },
  }
end

return M
