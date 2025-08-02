local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  local source = function(name)
    local types = require('cmp.types')
    return {
      name = name,
      entry_filter = function(entry, _)
        return types.lsp.CompletionItemKind[entry:get_kind()] ~= 'Text'
      end,
    }
  end

  return function()
    dofile(vim.g.base46_cache .. 'cmp')

    local cmp = require('cmp')
    local luasnip = require('luasnip')

    local options = {
      completion = { completeopt = 'menu,menuone,noselect' },
      window = {
        completion = { border = require('akirc').ui.borderStyle },
        documentation = { border = require('akirc').ui.borderStyle },
      },
      -- 设置代码片段引擎，用于根据代码片段补全
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
      -- 键盘映射
      mapping = cmp.mapping.preset.insert {
        -- 出现补全菜单
        ['<c-space>'] = cmp.mapping(function()
          if cmp.visible() then
            cmp.close()
          else
            cmp.complete()
          end
        end, { 'i', 'c' }),
        -- 选择下一个补全项
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item { behavior = require('cmp').SelectBehavior.Select }
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { 'i', 's' }),
        -- 选择上一个补全项
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
        -- 选择补全项
        ['<cr>'] = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true },
      },
      -- 显示补全预览
      experimental = { ghost_text = true },
      -- 补全来源
      sources = cmp.config.sources {
        { name = 'nvim_lsp' },
        source('luasnip'),
        source('path'),
        source('buffer'),
        { name = 'copilot' },
        { name = 'codeium' },
        { name = 'nvim_lua' },
        { name = 'cmp-dbee' },
      },
    }

    cmp.setup(vim.tbl_deep_extend('force', require('nvchad.cmp'), options))

    -- 预定义代码片段
    require('luasnip.loaders.from_vscode').lazy_load { exclude = vim.g.vscode_snippets_exclude or {} }
    require('luasnip.loaders.from_vscode').lazy_load { paths = vim.g.vscode_snippets_path or '' }
    require('luasnip.loaders.from_snipmate').load()
    require('luasnip.loaders.from_snipmate').lazy_load { paths = vim.g.snipmate_snippets_path or { './snippets' } }
    vim.api.nvim_create_autocmd('InsertLeave', {
      callback = function()
        if require('luasnip').session.current_nodes[vim.api.nvim_get_current_buf()] and not require('luasnip').session.jump_active then
          require('luasnip').unlink_current()
        end
      end,
    })

    -- 根据文件类型设置补全来源
    cmp.setup.filetype('gitcommit', {
      sources = cmp.config.sources { { name = 'buffer' } },
    })
    -- 命令模式下输入 `/`, `?` 启用补全
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = { { name = 'buffer' } },
    })
    -- 命令模式下输入 `:` 启用补全
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({ { name = 'path' } }, { { name = 'cmdline' } }),
    })

    vim.api.nvim_set_hl(0, 'CmpItemKindCopilot', { fg = '#4CCD99' })
    vim.api.nvim_set_hl(0, 'CmpItemKindCodeium', { fg = '#6CC644' })
  end
end

return M
