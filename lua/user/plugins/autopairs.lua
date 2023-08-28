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
  -- local cmp_autopairs = require "nvim-autopairs.completion.cmp"
  -- local cmp_status_ok, cmp = pcall(require, "cmp")
  -- if not cmp_status_ok then
  --   return
  -- end
  -- cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = { tex = "" } })
end

return M
