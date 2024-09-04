local M = {}

function M.config()
  -- do nothing
end

function M.setup(pre_hook)
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
    pre_hook = pre_hook,
  }
end

function M.docSetup()
  return {
    enabled = true,
    input_after_comment = true,
  }
end

return M
