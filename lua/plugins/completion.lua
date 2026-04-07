---@type packman.SpecItem[]
return {
  {
    'saghen/blink.cmp',
    version = 'v1.*',
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
      'windwp/nvim-autopairs',
      'xzbdmw/colorful-menu.nvim',
      'fang2hou/blink-copilot',
      { 'L3MON4D3/LuaSnip', version = 'v2.*' },
      'rafamadriz/friendly-snippets',
      'archie-judd/blink-cmp-words',
      'Kaiser-Yang/blink-cmp-avante',
    },
    config = function()
      require('blink.cmp').setup({
        completion = {
          trigger = { show_on_trigger_character = false },
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
          default = { 'lsp', 'snippets', 'copilot', 'path', 'buffer', 'avante' },
          providers = {
            lsp = {
              name = 'lsp',
              module = 'blink.cmp.sources.lsp',
              transform_items = function(_, items)
                for _, item in ipairs(items) do
                  if item.client_name == 'emmet_ls' or item.client_name == 'emmet_language_server' then item.score_offset = item.score_offset - 10 end
                end
                return items
              end,
            },
            snippets = { should_show_items = function(ctx) return ctx.trigger.initial_kind ~= 'trigger_character' end },
            copilot = { name = 'copilot', module = 'blink-copilot', async = true, opts = { kind_hl = 'BlickCmpItemKindCopilot' } },
            avante = { name = 'avante', module = 'blink-cmp-avante', opts = {} },
            thesaurus = {
              name = 'blink-cmp-words',
              module = 'blink-cmp-words.thesaurus',
              opts = {
                score_offset = 0,
                definition_pointers = { '!', '&', '^' },
                similarity_pointers = { '&', '^' },
                similarity_depth = 2,
              },
            },
            dictionary = {
              name = 'blink-cmp-words',
              module = 'blink-cmp-words.dictionary',
              opts = {
                dictionary_search_threshold = 3,
                score_offset = 0,
                definition_pointers = { '!', '&', '^' },
              },
            },
          },
          per_filetype = {
            text = { 'dictionary' },
            markdown = { 'lsp', 'thesaurus' },
            typst = { 'lsp', 'snippets', 'dictionary' },
            tex = { 'dictionary', 'thesaurus' },
          },
        },
      })
      require('colorful-menu').setup({
        ls = { gopls = { align_type_to_right = true, preserve_type_when_truncate = true } },
        max_width = 0.20,
      })
      require('luasnip.loaders.from_vscode').lazy_load()
      require('luasnip.loaders.from_vscode').lazy_load({ paths = { './snippets' } })
      vim.api.nvim_set_hl(0, 'BlickCmpItemKindCopilot', { fg = '#60B5FF' })
      require('nvim-autopairs').setup({
        disable_filetype = { 'snacks_picker_input' },
        check_ts = true,
        ts_config = { lua = { 'string' }, javascript = { 'template_string' }, java = false },
      })
    end,
  },
}
