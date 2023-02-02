local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  local status, cmp = pcall(require, "cmp")
  if not status then
    vim.notify("cmp 没有加载或未安装")
    return
  end

  ---@diagnostic disable-next-line: redundant-parameter
  cmp.setup({
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
    mapping = cmp.mapping.preset.insert({
      -- 选择下一个补全项
      ['<tab>'] = cmp.mapping.select_next_item(),
      -- 选择上一个补全项
      ['<s-tab>'] = cmp.mapping.select_prev_item(),
      -- 出现补全菜单
      ['<C-space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      -- 选择补全项
      ['<CR>'] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      }),
    }),
    -- 补全来源
    sources = {
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'buffer' },
      { name = 'path' },
    },
    -- 根据文件类型设置补全来源
    cmp.setup.filetype('gitcommit', {
      sources = cmp.config.sources({
        { name = 'buffer' },
      }),
    }),
    -- 命令模式下输入 `/`, `?` 启用补全
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' }
      },
    }),
    -- 命令模式下输入 `:` 启用补全
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' }
      }, {
        { name = 'cmdline' }
      }),
    }),
    -- 设置补全显示的格式
    formatting = {
      format = require('lspkind').cmp_format({
        -- 显示的最大字符
        maxwidth = 50,
        -- 超过最大字符后显示的字符
        ellipsis_char = '...',
        -- 显示的图标
        symbol_map = {
          Text = "",
          Method = "",
          Function = "",
          Constructor = "",
          Field = "ﰠ",
          Variable = "",
          Class = "ﴯ",
          Interface = "",
          Module = "",
          Property = "ﰠ",
          Unit = "塞",
          Value = "",
          Enum = "",
          Keyword = "",
          Snippet = "",
          Color = "",
          File = "",
          Reference = "",
          Folder = "",
          EnumMember = "",
          Constant = "",
          Struct = "פּ",
          Event = "",
          Operator = "",
          TypeParameter = "",
        },
        -- 设置补全项的前缀
        before = function(entry, vim_item)
          vim_item.menu = "[" .. string.upper(entry.source.name) .. "]"
          return vim_item
        end
      }),
    },
  })
end

return M
