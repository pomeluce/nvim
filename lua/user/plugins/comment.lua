local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return {
    -- N 模式注释快捷键
    toggler = {
      line = '<leader>/',
      block = '<leader><leader>/',
    },
    -- V 模式注释快捷键
    opleader = {
      line = '<leader>/',
      block = '<leader><leader>/',
    },
    -- 启用快捷键
    mappings = {
      basic = true,
      extra = false,
    },
  }
end

return M
