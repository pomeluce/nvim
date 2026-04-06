---@type packman.SpecItem[]
return {
  {
    'Bekaboo/dropbar.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      bar = {
        enable = function(buf, win, _)
          buf = vim._resolve_bufnr(buf)
          if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then return false end
          if vim.fn.win_gettype(win) ~= '' or vim.wo[win].winbar ~= '' or vim.bo[buf].ft == 'help' or vim.bo[buf].ft == 'NvimTree' then return false end
          local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
          if stat and stat.size > 1024 * 1024 then return false end
          return vim.bo[buf].ft == 'markdown'
            or pcall(vim.treesitter.get_parser, buf)
            or not vim.tbl_isempty(vim.lsp.get_clients({ bufnr = buf, method = 'textDocument/documentSymbol' }))
        end,
      },
      menu = { preview = false, scrollbar = { enable = true, background = false } },
    },
  },
}
