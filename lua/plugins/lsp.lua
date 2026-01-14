vim.pack.add({
  { src = 'https://github.com/neovim/nvim-lspconfig' },
})

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

local hlword = require('configs.hlword')
local map = vim.keymap.set
-- 诊断样式
local x = vim.diagnostic.severity
vim.diagnostic.config({
  virtual_text = { spacing = 4, prefix = '' },
  signs = { text = { [x.ERROR] = '', [x.WARN] = '', [x.INFO] = '', [x.HINT] = '' } },
  severity_sort = true,
  float = { severity_sort = true },
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('SetupLSP', { clear = true }),
  callback = function(event)
    -- 当前 LSP 客户端
    local client = assert(vim.lsp.get_client_by_id(event.data.client_id))

    -- 代码折叠 LSP 支持
    -- if client and client:supports_method('textDocument/foldingRange') then
    --   local win = vim.api.nvim_get_current_win()
    --   vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
    -- end

    -- 关闭 LSP 自带的颜色高亮
    vim.lsp.document_color.enable(false, event.buf)

    -- 内联提示
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      local function inlay_hint() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })) end
      map('n', '<leader>th', inlay_hint, { buffer = event.buf, desc = 'LSP: Toggle Inlay Hints' })
    end

    -- 高亮光标单词
    local group = vim.api.nvim_create_augroup('HLCurrsorWord', { clear = true })
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      buffer = event.buf,
      group = group,
      callback = function(ev)
        if has_document_highlight(ev.buf) then
          vim.lsp.buf.document_highlight()
        else
          hlword.highlight_word()
        end
      end,
    })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      buffer = event.buf,
      group = group,
      callback = function()
        vim.lsp.buf.clear_references()
        hlword.clear_word()
      end,
    })
    -- LSP 断连清除所有高亮
    vim.api.nvim_create_autocmd('LspDetach', {
      group = vim.api.nvim_create_augroup('DetachLSP', { clear = true }),
      callback = function()
        hlword.clear_word()
        vim.lsp.buf.clear_references()
      end,
    })

    -- 重命名
    map('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'LSP: Rename Symbol' })

    -- 调用 LSP 代码定义功能, 若无定义则提示
    map('n', 'gd', jump('textDocument/definition', Snacks.picker.lsp_definitions, 'No definition found'), { buffer = event.buf, desc = 'LSP: Goto Definition' })

    -- 根据窗口大小智能分屏跳转到定义
    map('n', 'gD', function()
      local win = vim.api.nvim_get_current_win()
      local width = vim.api.nvim_win_get_width(win)
      local height = vim.api.nvim_win_get_height(win)

      -- 模仿 tmux 公式：8 * 宽度 - 20 * 高度
      local value = 8 * width - 20 * height
      if value < 0 then
        vim.cmd('split') -- vertical space is more: horizontal split
      else
        vim.cmd('vsplit') -- horizontal space is more: vertical split
      end

      vim.lsp.buf.definition()
    end, { buffer = event.buf, desc = 'LSP: Goto Definition (split)' })

    -- 调用 LSP 代码实现功能, 若无实现则提示
    map('n', 'gi', jump('textDocument/implementation', Snacks.picker.lsp_implementations, 'No implementation found'), { buffer = event.buf, desc = 'LSP: Goto Implementation' })

    -- 跳转到错误位置
    map('n', 'ge', function()
      -- 优先级: ERROR > WARN > HINT
      local severities = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN, vim.diagnostic.severity.HINT }

      for _, severity in ipairs(severities) do
        local diag = vim.diagnostic.get_next({ bufnr = 0, severity = severity })
        if diag then
          vim.diagnostic.open_float()
          vim.api.nvim_win_set_cursor(0, { diag.lnum + 1, diag.col })
          vim.schedule(function() vim.diagnostic.open_float({ scope = 'cursor', source = true, pos = { diag.lnum, diag.col or 0 } }) end)
          return
        end
      end

      vim.notify('No diagnostic found', vim.log.levels.INFO)
    end, { buffer = event.buf, desc = 'LSP: Goto Next Diagnostic' })

    -- 代码修复提示
    map({ 'n', 'i' }, '<a-cr>', vim.lsp.buf.code_action, { buffer = event.buf, desc = 'LSP: Code Action' })

    -- 显示悬停文档
    map('n', 'K', vim.lsp.buf.hover, { buffer = event.buf, desc = 'LSP: Hover Documentation' })
  end,
})
