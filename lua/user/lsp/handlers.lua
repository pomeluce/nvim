local M = {}

M.setup = function()
  -- 设置高亮标签
  local signs = {
    { name = 'DiagnosticSignError', text = '' },
    { name = 'DiagnosticSignWarn', text = '' },
    { name = 'DiagnosticSignHint', text = '' },
    { name = 'DiagnosticSignInfo', text = '' },
  }

  -- 设置标签
  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { text = sign.text, texthl = sign.name, numhl = '' })
  end

  -- 诊断配置
  local config = {
    -- 禁用虚拟文本
    virtual_text = false,
    -- 显示 signs
    signs = {
      active = true,
    },
    -- 再插入模式下，显示诊断信息
    update_in_insert = true,
    -- 设置下划线
    underline = true,
    -- 对诊断信息进行排序
    severity_sort = true,
    -- 浮动窗口
    float = {
      focusable = false,
      style = 'minimal',
      border = 'rounded',
      source = 'always',
      header = '',
      prefix = '',
    },
  }
  -- 设置诊断配置
  vim.diagnostic.config(config)

  -- 悬浮窗口添加边框
  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = 'rounded',
  })

  -- 签名帮助添加边框
  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = 'single',
  })
end

M.lsp_highlight_document = function(client)
  -- 以 server_capabilities 设置自动命令
  if client.server_capabilities.documentHighlight then
    -- 清除当前缓冲区中的所有高亮命名空间
    vim.api.nvim_buf_clear_namespace(0, vim.fn.bufnr(), 0, -1)
    local lsp_highlight_document = vim.api.nvim_create_augroup('lsp_highlight_document')
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

M.on_attach = function(client, buffer)
  require('user.core.keymap').lsp_keymaps(buffer)
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
