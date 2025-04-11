local M = {}

M.sign_define = function()
  local x = vim.diagnostic.severity

  vim.diagnostic.config {
    virtual_text = { prefix = '' },
    signs = { text = { [x.ERROR] = '󰅙', [x.WARN] = '', [x.INFO] = '󰋼', [x.HINT] = '󰌵' } },
    underline = true,
    float = { border = 'single' },
  }

  -- Default border style
  local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
  ---@diagnostic disable-next-line: duplicate-set-field
  function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = require('akirc').ui.borderStyle
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
  end
end

M.lsp_highlight_document = function(client)
  -- 以 server_capabilities 设置自动命令
  if client.server_capabilities.documentHighlight then
    -- 清除当前缓冲区中的所有高亮命名空间
    vim.api.nvim_buf_clear_namespace(0, vim.fn.bufnr(), 0, -1)
    local lsp_highlight_document = vim.api.nvim_create_augroup('lsp_highlight_document', { clear = false })
    vim.api.nvim_create_autocmd('CursorHold', {
      group = lsp_highlight_document,
      pattern = '*',
      callback = function()
        vim.lsp.buf.document_highlight()
      end,
    })

    vim.api.nvim_create_autocmd('CursorHold', {
      group = lsp_highlight_document,
      pattern = '*',
      callback = function()
        vim.lsp.buf.clear_references()
      end,
    })
  end
end

-- disable semanticTokens
M.on_init = function(client, _)
  if client.supports_method('textDocument/semanticTokens') then
    client.server_capabilities.semanticTokensProvider = nil
  end
end
M.on_attach = function(client, bufnr)
  require('user.core.keymaps').lsp_keymaps(bufnr)
  M.lsp_highlight_document(client)
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { 'markdown', 'plaintext' },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      'documentation',
      'detail',
      'additionalTextEdits',
    },
  },
}

M.setup = function()
  dofile(vim.g.base46_cache .. 'lsp')
  local mason = require('user.lsp.mason')

  -- lsp 配置
  for _, server in pairs(mason.lsp_servers) do
    local opt = {
      on_attach = M.on_attach,
      capabilities = M.capabilities,
      on_init = M.on_init,
    }
    local result, config = pcall(require, 'user.lsp.config.' .. server)
    if result then
      require('lspconfig')[server].setup(vim.tbl_deep_extend('keep', opt, config))
    end
  end
end

return M
