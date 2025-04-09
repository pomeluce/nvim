local icons = require('user.icons')

local M = {}

M.sign_define = function()
  local diagnostic_icons = icons.diagnostic_icons

  -- 设置高亮标签
  vim.diagnostic.config {
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = diagnostic_icons.error,
        [vim.diagnostic.severity.WARN] = diagnostic_icons.warn,
        [vim.diagnostic.severity.INFO] = diagnostic_icons.info,
        [vim.diagnostic.severity.HINT] = diagnostic_icons.hint,
      },
    },
  }
end

M.setup = function()
  -- lspinfo 添加边框
  require('lspconfig.ui.windows').default_options.border = 'rounded'
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

M.on_attach = function(client, bufnr)
  require('user.core.keymaps').lsp_keymaps(bufnr)
  M.lsp_highlight_document(client)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

local status_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if not status_ok then
  vim.notify('cmp_nvim_lsp 未找到')
  return
end

M.capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

return M
