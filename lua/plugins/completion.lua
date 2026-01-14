vim.pack.add({
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('v1.*') },
  { src = 'https://github.com/altermo/ultimate-autopair.nvim' },
  { src = 'https://github.com/xzbdmw/colorful-menu.nvim' },
  { src = 'https://github.com/fang2hou/blink-copilot' },
  { src = 'https://github.com/L3MON4D3/LuaSnip', version = vim.version.range('v2.*') },
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
  { src = 'https://github.com/archie-judd/blink-cmp-words' },
})

vim.api.nvim_create_autocmd({ 'InsertEnter', 'CmdlineEnter' }, {
  group = vim.api.nvim_create_augroup('SetupCompletion', { clear = true }),
  once = true,
  callback = function()
    require('blink.cmp').setup({
      completion = {
        documentation = { auto_show = true, window = { border = 'rounded', scrollbar = true } },
        menu = {
          border = 'rounded',
          auto_show = true,
          auto_show_delay_ms = 0,
          scrollbar = true,
          max_height = 14,
          draw = {
            columns = { { 'label', gap = 3 }, { 'kind_icon' }, { 'kind' }, { 'source_name' } },
            components = {
              label = { text = function(ctx) return require('colorful-menu').blink_components_text(ctx) end },
              source_name = {
                text = function(ctx)
                  if not ctx.source_name or ctx.source_name == '' then return '' end
                  return '[' .. ctx.source_name .. ']'
                end,
              },
            },
          },
        },
        ghost_text = { enabled = true },
        list = { selection = { preselect = true, auto_insert = true } },
      },
      snippets = { preset = 'luasnip' },
      signature = { enabled = true },
      keymap = {
        -- 禁用默认快捷键
        preset = 'none',
        ['<c-space>'] = { 'show', 'hide' },
        ['<tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<s-tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
        ['<cr>'] = { 'select_and_accept', 'fallback' },
      },
      cmdline = { keymap = { preset = 'inherit' }, completion = { menu = { auto_show = true } } },
      sources = {
        default = { 'lsp', 'snippets', 'copilot', 'path', 'buffer' },
        providers = {
          -- 避免在 . " ' 字符之后触发片段
          snippets = { should_show_items = function(ctx) return ctx.trigger.initial_kind ~= 'trigger_character' end },
          copilot = { name = 'copilot', module = 'blink-copilot', score_offset = 100, async = true, opts = { kind_hl = 'BlickCmpItemKindCopilot' } },
          -- 使用同义词词典来源
          thesaurus = {
            name = 'blink-cmp-words',
            module = 'blink-cmp-words.thesaurus',
            -- 所有可用选项
            opts = {
              -- A score offset applied to returned items.
              -- By default the highest score is 0 (item 1 has a score of -1, item 2 of -2 etc..).
              score_offset = 0,

              -- Default pointers define the lexical relations listed under each definition,
              -- see Pointer Symbols below.
              -- Default is as below ("antonyms", "similar to" and "also see").
              definition_pointers = { '!', '&', '^' },

              -- The pointers that are considered similar words when using the thesaurus,
              -- see Pointer Symbols below.
              -- Default is as below ("similar to", "also see" }
              similarity_pointers = { '&', '^' },

              -- The depth of similar words to recurse when collecting synonyms. 1 is similar words,
              -- 2 is similar words of similar words, etc. Increasing this may slow results.
              similarity_depth = 2,
            },
          },
          -- 使用词典来源
          dictionary = {
            name = 'blink-cmp-words',
            module = 'blink-cmp-words.dictionary',
            -- All available options
            opts = {
              -- The number of characters required to trigger completion.
              -- Set this higher if completion is slow, 3 is default.
              dictionary_search_threshold = 3,

              -- See above
              score_offset = 0,

              -- See above
              definition_pointers = { '!', '&', '^' },
            },
          },
        },
        -- 按文件类型完成设置
        per_filetype = {
          text = { 'dictionary' },
          markdown = { 'lsp', 'thesaurus' },
          typst = { 'lsp', 'snippets', 'dictionary' },
          tex = { 'dictionary', 'thesaurus' },
        },
      },
    })
    require('ultimate-autopair').setup({})
    require('colorful-menu').setup({
      ls = {
        gopls = {
          -- 默认情况下, 我们将变量/函数的类型呈现在最右侧, 以避免它们与原标签拥挤在一起。
          -- when true:
          --    foo             *Foo
          --    ast         "go/ast"

          -- when false:
          --    foo *Foo
          --    ast "go/ast"
          align_type_to_right = true,
          -- See https://github.com/xzbdmw/colorful-menu.nvim/pull/36
          preserve_type_when_truncate = true,
        },
      },
      max_width = 0.20,
    })
    -- load luasnip
    require('luasnip.loaders.from_vscode').lazy_load() -- 添加 friendly-snippets 片段
    require('luasnip.loaders.from_vscode').lazy_load({ paths = { './snippets' } }) -- 添加自定义片段
    vim.api.nvim_set_hl(0, 'BlickCmpItemKindCopilot', { fg = '#3750F8' })
  end,
})
