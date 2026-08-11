---@param method (vim.lsp.protocol.Method.ClientToServer.Request) LSP method name
local function jump(method, picker, message)
  return function()
    local params = vim.lsp.util.make_position_params(0, 'utf-8')
    vim.lsp.buf_request(0, method, params, function(_, result, _, _)
      if not result or vim.tbl_isempty(result) then
        vim.notify(message or 'No result found', vim.log.levels.INFO)
      else
        picker()
      end
    end)
  end
end

local function has_document_highlight(bufnr)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then return true end
  end
  return false
end

local map = vim.keymap.set
local hlword = require('configs.hlword')
local document_highlight_method = vim.lsp.protocol.Methods.textDocument_documentHighlight
local document_highlight_handler = vim.lsp.handlers[document_highlight_method]
local highlight_group = vim.api.nvim_create_augroup('LspReferenceHighlight', { clear = true })

-- LSP responses can arrive after their source buffer has been deleted.
vim.lsp.handlers[document_highlight_method] = function(err, result, ctx, config)
  if not vim.api.nvim_buf_is_valid(ctx.bufnr) then return end
  return document_highlight_handler(err, result, ctx, config)
end

local function setup_reference_highlight(bufnr)
  vim.api.nvim_clear_autocmds({ group = highlight_group, buffer = bufnr })

  vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
    group = highlight_group,
    buffer = bufnr,
    callback = function(ev)
      if has_document_highlight(ev.buf) then
        vim.lsp.buf.document_highlight()
      else
        hlword.highlight_word()
      end
    end,
  })

  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
    group = highlight_group,
    buffer = bufnr,
    callback = function(ev)
      if vim.api.nvim_buf_is_valid(ev.buf) then vim.lsp.util.buf_clear_references(ev.buf) end
      hlword.clear_word()
    end,
  })

  vim.api.nvim_create_autocmd('LspDetach', {
    group = highlight_group,
    buffer = bufnr,
    callback = function(ev)
      if vim.api.nvim_buf_is_valid(ev.buf) then vim.lsp.util.buf_clear_references(ev.buf) end
      hlword.clear_word()
    end,
  })
end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    PackUtils.load({ name = 'nvim-lspconfig' })
    local client = assert(vim.lsp.get_client_by_id(event.data.client_id))

    vim.diagnostic.config({
      virtual_text = { spacing = 4, prefix = '' },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = '',
          [vim.diagnostic.severity.WARN] = '',
          [vim.diagnostic.severity.INFO] = '',
          [vim.diagnostic.severity.HINT] = '',
        },
      },
      severity_sort = true,
      float = { severity_sort = true },
    })

    -- 代码折叠 LSP 支持
    -- if client and client:supports_method('textDocument/foldingRange') then
    --   local win = vim.api.nvim_get_current_win()
    --   vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
    -- end

    -- 关闭 LSP 自带的颜色高亮
    vim.lsp.document_color.enable(false)

    -- 内联提示
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      local function inlay_hint() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })) end
      map('n', '<leader>th', inlay_hint, { buffer = event.buf, desc = 'LSP: Toggle Inlay Hints' })
    end

    -- 高亮光标单词
    setup_reference_highlight(event.buf)

    -- 重命名
    local opts = function(desc) return { buffer = event.buf, desc = desc } end
    map('n', '<leader>rn', vim.lsp.buf.rename, opts('LSP: Rename Symbol'))
    -- 调用 LSP 代码定义功能, 若无定义则提示
    map(
      'n',
      'gd',
      jump('textDocument/definition', function()
        if _G.Snacks then
          Snacks.picker.lsp_definitions()
        else
          vim.lsp.buf.definition()
        end
      end, 'No definition found'),
      opts('LSP: Goto Definition')
    )
    -- 根据窗口大小智能分屏跳转到定义
    map('n', 'gD', function()
      local win = vim.api.nvim_get_current_win()
      local width = vim.api.nvim_win_get_width(win)
      local height = vim.api.nvim_win_get_height(win)
      local value = 8 * width - 20 * height
      if value < 0 then
        vim.cmd('split')
      else
        vim.cmd('vsplit')
      end
      vim.lsp.buf.definition()
    end, opts('LSP: Goto Definition (split)'))
    -- 调用 LSP 代码实现功能, 若无实现则提示
    map(
      'n',
      'gi',
      jump('textDocument/implementation', function()
        if _G.Snacks then
          Snacks.picker.lsp_implementations()
        else
          vim.lsp.buf.implementation()
        end
      end, 'No implementation found'),
      opts('LSP: Goto Implementation')
    )
    -- 跳转到错误位置
    map('n', 'ge', function()
      -- 优先级: ERROR > WARN > HINT
      local severities = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN, vim.diagnostic.severity.HINT }
      for _, severity in ipairs(severities) do
        local diag = vim.diagnostic.get_next({ bufnr = 0, severity = severity })
        if diag then
          vim.diagnostic.open_float()
          vim.api.nvim_win_set_cursor(0, { diag.lnum + 1, diag.col })
          vim.schedule(
            function()
              vim.diagnostic.open_float({
                scope = 'cursor',
                source = true,
                pos = { diag.lnum, diag.col or 0 },
              })
            end
          )
          return
        end
      end
      vim.notify('No diagnostic found', vim.log.levels.INFO)
    end, opts('LSP: Goto Next Diagnostic'))
    -- 代码修复提示
    map({ 'n', 'i' }, '<a-cr>', vim.lsp.buf.code_action, opts('LSP: Code Action'))
    -- 显示悬停文档
    map('n', 'K', vim.lsp.buf.hover, opts('LSP: Hover Documentation'))
  end,
})
