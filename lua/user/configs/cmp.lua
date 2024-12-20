local M = {}

local source = function(name, types)
  return {
    name = name,
    entry_filter = function(entry, _)
      local kind = types.lsp.CompletionItemKind[entry:get_kind()]
      if kind == 'Text' then
        return false
      end
      return true
    end,
  }
end

function M.config()
  -- do nothing
end

function M.cmp_cmdline(cmp)
  -- 根据文件类型设置补全来源
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources {
      { name = 'buffer' },
    },
  })
  -- 命令模式下输入 `/`, `?` 启用补全
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' },
    },
  })
  -- 命令模式下输入 `:` 启用补全
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' },
    }, {
      { name = 'cmdline' },
    }),
  })
end

function M.setup(cmp, types)
  local lspkind = require('lspkind')
  local luasnip = require('luasnip')
  return {
    -- 设置代码片段引擎，用于根据代码片段补全
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
    -- 显示边框
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
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
          cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
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
    experimental = {
      ghost_text = true,
    },
    -- 补全来源
    sources = cmp.config.sources {
      { name = 'nvim_lsp' },
      source('luasnip', types),
      source('path', types),
      source('buffer', types),
      { name = 'copilot' },
      { name = 'codeium' },
      -- { name = 'nvim_lua' },
    },
    -- 设置补全显示的格式
    formatting = {
      format = lspkind.cmp_format {
        -- 显示的最大字符
        maxwidth = 50,
        -- 超过最大字符后显示的字符
        ellipsis_char = '...',
        -- 显示的图标
        symbol_map = {
          Text = '󰉿',
          Method = '󰆧',
          Function = '󰊕',
          Constructor = '',
          Field = '󰜢',
          Variable = '󰀫',
          Class = '󰠱',
          Interface = '',
          Module = '󰕳',
          Property = '󰓻',
          Unit = '󰚯',
          Value = '󰎠',
          Enum = '',
          Keyword = '󰌋',
          Snippet = '',
          Color = '󰏘',
          File = '󰈙',
          Reference = '󰈇',
          Folder = '󰉋',
          EnumMember = '',
          Constant = '󰏿',
          Struct = '󰙅',
          Event = '',
          Operator = '󰆕',
          TypeParameter = '󰊄',
          Copilot = '',
          Codeium = '',
        },
        -- 设置补全项的前缀
        before = function(entry, vim_item)
          vim_item.menu = '[' .. string.upper(entry.source.name) .. ']'
          return vim_item
        end,
      },
    },
  }
end

return M
