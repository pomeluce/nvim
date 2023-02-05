local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  local status_ok, autopairs = pcall(require, "nvim-autopairs")
  if not status_ok then
    vim.notify('nvim-autopairs 没有加载或未安装')
    return
  end

  local setting = {
    check_ts = true,
    ts_config = {
      -- 不在该节点添加 autopairs
      lua = { 'string', 'source' },
      javascript = { 'template_string' },
      -- 不对 java 进行 treesitter 检查
      java = false,
    },
  }

  autopairs.setup(setting)

  local cmp_autopairs = require "nvim-autopairs.completion.cmp"
  local cmp_status_ok, cmp = pcall(require, "cmp")
  if not cmp_status_ok then
    return
  end
  cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = { tex = "" } })
end

return M
