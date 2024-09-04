local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return {
    check_ts = true,
    ts_config = {
      -- 不在该节点添加 autopairs
      lua = { 'string', 'source' },
      javascript = { 'template_string' },
      -- 不对 java 进行 treesitter 检查
      java = false,
    },
  }
end

return M
