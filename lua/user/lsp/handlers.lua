local M = {}

local akirc = require('akirc')

M.init = function()
  return function()
    local x = vim.diagnostic.severity

    vim.diagnostic.config {
      virtual_text = { prefix = '' },
      signs = { text = { [x.ERROR] = '󰅙', [x.WARN] = '', [x.INFO] = '󰋼', [x.HINT] = '󰌵' } },
      underline = true,
      float = { border = akirc.ui.borderStyle },
    }

    -- Default border style
    local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
      opts = opts or {}
      opts.border = akirc.ui.borderStyle
      return orig_util_open_floating_preview(contents, syntax, opts, ...)
    end
  end
end

M.setup = function()
  return function()
    dofile(vim.g.base46_cache .. 'lsp')
    local mason = require('user.lsp.mason')
    local autocmd = vim.api.nvim_create_autocmd

    autocmd('LspAttach', {
      callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
          return
        end

        require('user.core.mappings').lsp(bufnr)
        -- 以 server_capabilities 设置自动命令
        if client.server_capabilities.documentHighlight then
          -- 清除当前缓冲区中的所有高亮命名空间
          vim.api.nvim_buf_clear_namespace(0, vim.fn.bufnr(), 0, -1)
          local lsp_highlight_document = vim.api.nvim_create_augroup('lsp_highlight_document', { clear = false })
          autocmd('CursorHold', {
            group = lsp_highlight_document,
            pattern = '*',
            callback = function()
              vim.lsp.buf.document_highlight()
            end,
          })

          autocmd('CursorHold', {
            group = lsp_highlight_document,
            pattern = '*',
            callback = function()
              vim.lsp.buf.clear_references()
            end,
          })
        end
      end,
    })

    -- lsp 配置
    for _, server in pairs(mason.lsp_servers) do
      local opt = {
        capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), {
          textDocument = {
            completion = {
              completionItem = {
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
              },
            },
          },
        }),
        on_init = function(client, _)
          if client.supports_method('textDocument/semanticTokens') then
            -- disable semanticTokens
            client.server_capabilities.semanticTokensProvider = nil
          end
        end,
      }
      local ok, config = pcall(require, 'user.lsp.config.' .. server)
      if ok then
        vim.lsp.config(server, vim.tbl_deep_extend('keep', opt, config))
        vim.lsp.enable(server)
      end
    end
  end
end

return M
