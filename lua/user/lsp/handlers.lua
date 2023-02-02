local M = {}

M.setup = function()
  -- 设置高亮标签
  local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
  }

  -- 设置标签
  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { text = sign.text, texthl = sign.name, numhl = "" })
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
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }
  -- 设置诊断配置
  vim.diagnostic.config(config)

  -- 悬浮窗口添加边框
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })

  -- 签名帮助添加边框
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "single"
  })
end

local function lsp_highlight_document(client)
  -- 以 server_capabilities 设置自动命令
  if client.server_capabilities.documentHighlight then
    vim.api.nvim_exec([[
      augroup lsp_highlight_document 
        autocmd! * <buffer>
        autocmd CursorHold * lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved * lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end
end

local function lsp_keymaps(bufnr)
  -- 快捷键设置
  local buf_map = vim.api.nvim_buf_set_keymap
  -- 重命名
  buf_map( bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', { noremap = true, silent = true } )
  -- TODO: goto 跳转
  -- 跳转到定义
  buf_map( bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', { noremap = true, silent = true } )
  -- 跳转到类型定义
  buf_map( bufnr, 'n', 'gy', '<cmd>lua vim.lsp.buf.type_definition()<cr>', { noremap = true, silent = true } )
  -- 跳转到实现
  buf_map( bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', { noremap = true, silent = true } )
  -- 跳转到引用
  buf_map( bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', { noremap = true, silent = true } )
  -- 跳转到错误
  buf_map( bufnr, 'n', 'ge', '<cmd>lua vim.diagnostic.goto_next()<cr>', { noremap = true, silent = true } )
  -- TODO: 补全设置
  -- 显示文档
  buf_map( bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true } )
  -- code action 代码修复
  buf_map( bufnr, 'n', '<m-cr>', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true } )
  buf_map( bufnr, 'v', '<m-cr>', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true } )
  -- 格式化命令
  vim.cmd([[ command! Format execute 'lua vim.lsp.buf.format { async = true }' ]])
  -- 设置格式化快捷键
  -- G.map({
  --   { 'n', '<leader>fm', ':Format<CR>', { noremap = true, silent = true } },
  --   { 'v', '<leader>fm', ':Format<CR>', { noremap = true, silent = true } },
  -- })
end

M.on_attach = function(client, bufnr)
  if client.name == "tsserver" then
    client.server_capabilities.documentFormattingProvider = false
  end
  lsp_keymaps(bufnr)
  lsp_highlight_document(client)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ok then
  vim.notify('cmp_nvim_lsp 未找到')
  return
end

M.capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

return M
