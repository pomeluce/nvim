local M = {}

function M.config()
  vim.g.vsnip_snippet_dir = os.getenv("HOME") .. "/.config/nvim/snippets"
end

function M.setup()
end

return M
