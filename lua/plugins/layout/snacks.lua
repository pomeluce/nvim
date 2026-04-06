---@type packman.SpecItem[]
return {
  {
    'folke/snacks.nvim',
    config = function()
      _G.Snacks = require('snacks')

      Snacks.setup({
        picker = {
          prompt = ' 󱁴 ',
          layout = { layout = { width = 0.5, height = 0.6, preview = { size = 0.6 } } },
          matcher = { frecency = true, cwd_bonus = true, history_bonus = true },
          formatters = { icon_width = 3 },
          win = { input = { keys = { ['<leader>c'] = { 'close', mode = { 'i' } } } } },
        },
        dashboard = {
          enabled = true,
          preset = {
            keys = {
              { icon = ' ', key = 'l', desc = 'Project Discover', action = ':NeovimProjectDiscover' },
              { icon = ' ', key = 'p', desc = 'Project History', action = ':NeovimProjectHistory' },
              { icon = '󱦞 ', key = 'f', desc = 'Find Files', action = ':lua Snacks.picker.smart()' },
              { icon = '󱔗 ', key = 'e', desc = 'New File', action = ':enew' },
              { icon = ' ', key = 'm', desc = 'Keymap Discover', action = ':lua Snacks.picker.keymaps({ layout = "dropdown" })' },
              { icon = '󰿅 ', key = 'q', desc = 'Quit Editor', action = ':qa' },
            },
            header = [[
░░      ░░░  ░░░░  ░░        ░░       ░░░   ░░░  ░░  ░░░░  ░
▒  ▒▒▒▒  ▒▒  ▒▒▒  ▒▒▒▒▒▒  ▒▒▒▒▒  ▒▒▒▒  ▒▒    ▒▒  ▒▒  ▒▒▒▒  ▒
▓  ▓▓▓▓  ▓▓     ▓▓▓▓▓▓▓▓  ▓▓▓▓▓       ▓▓▓  ▓  ▓  ▓▓▓  ▓▓  ▓▓
█        ██  ███  ██████  █████  ███  ███  ██    ████    ███
█  ████  ██  ████  ██        ██  ████  ██  ███   █████  ████
                                                            
                                                            
                    [  AKIRVIM EDITOR ]                    
]],
          },
          sections = {
            { section = 'header' },
            { section = 'keys', padding = 1, gap = 1 },
          },
        },
        terminal = { win = { style = 'float', width = math.floor(vim.o.columns * 0.6), height = math.floor(vim.o.lines * 0.65), border = 'rounded' } },
      })

      local map = vim.keymap.set
      map('n', '<leader>ff', function() Snacks.picker.smart({ multi = { 'buffers', 'files' } }) end, { desc = 'Smart file picker' })
      map('n', '<leader>fb', function() Snacks.picker.buffers({ sort_lastused = true }) end, { desc = 'Find buffer' })
      map('n', '<leader>fo', Snacks.picker.recent, { desc = 'Find recent file' })
      map('n', '<leader>fw', Snacks.picker.grep, { desc = 'Live grep in files' })
      map('n', '<leader>fW', function() Snacks.picker.lines({ layout = 'dropdown' }) end, { desc = 'Live grep in current buffer' })
      map('n', '<leader>fh', function() Snacks.picker.help({ layout = 'dropdown' }) end, { desc = 'Find in help' })
      map('n', '<leader>fl', Snacks.picker.picker_layouts, { desc = 'Find snacks picker layouts' })
      map('n', '<leader>fk', function() Snacks.picker.keymaps({ layout = 'dropdown' }) end, { desc = 'Find keymaps with snacks' })
      map('n', '<leader>fi', function() Snacks.picker.icons({ layout = 'dropdown' }) end, { desc = 'Find icons' })
      local function find_todo()
        if vim.bo.filetype == 'markdown' then
          Snacks.picker.grep_buffers({
            finder = 'grep',
            format = 'file',
            prompt = ' ',
            search = '^\\s*- \\[ \\]',
            regex = true,
            live = false,
            args = { '--no-ignore' },
            on_show = function() vim.cmd.stopinsert() end,
            buffers = false,
            supports_live = false,
            layout = 'ivy',
          })
        else
          Snacks.picker.todo_comments({ layout = 'select' })
        end
      end
      map('n', '<leader>ft', find_todo, { desc = 'Find TODO comments' })
      map('n', '<leader>fd', Snacks.picker.diagnostics_buffer, { desc = 'Find diagnostic in current buffer' })
      map('n', '<leader>fH', Snacks.picker.highlights, { desc = 'Find highlights' })
      local function lsp_buffer_symbols()
        local bufnr = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients({ bufnr = bufnr })
        local function _has_lsp_symbols()
          for _, client in ipairs(clients) do
            if client.server_capabilities.documentSymbolProvider then return true end
          end
          return false
        end
        if _has_lsp_symbols() then
          Snacks.picker.lsp_symbols({ layout = 'dropdown', tree = true })
        else
          Snacks.picker.treesitter()
        end
      end
      map('n', '<leader>fs', lsp_buffer_symbols, { desc = 'Find symbols in current buffer' })
      map('n', '<leader>fS', Snacks.picker.lsp_workspace_symbols, { desc = 'Find symbols in workspace' })
      map('n', 'grr', function() Snacks.picker.lsp_references({ include_declaration = false, include_current = true }) end, { desc = 'Find lsp references' })
      map({ 'n', 't' }, '<c-t>', Snacks.terminal.toggle, { desc = 'Toggle float terminal' })

      -- 命名风格转换 (from plugins.edit.case-convert)
      local cc = {}
      function cc.parse_words(text)
        local words = {}
        for word in text:gmatch('[^_.%- ]+') do
          table.insert(words, word)
        end
        if #words == 1 then
          local word = words[1]
          words = {}
          for part in word:gmatch('[A-Z]+[a-z]*|[a-z]+') do
            table.insert(words, part)
          end
          if #words == 0 then words = { text } end
        end
        for i, w in ipairs(words) do
          words[i] = w:lower()
        end
        return words
      end
      cc.converters = {
        ['snake_case'] = function(words) return table.concat(words, '_') end,
        ['kebab-case'] = function(words) return table.concat(words, '-') end,
        ['camelCase'] = function(words)
          local result = words[1] or ''
          for i = 2, #words do
            result = result .. words[i]:sub(1, 1):upper() .. words[i]:sub(2)
          end
          return result
        end,
        ['PascalCase'] = function(words)
          local result = ''
          for _, w in ipairs(words) do
            result = result .. w:sub(1, 1):upper() .. w:sub(2)
          end
          return result
        end,
        ['UPPER_CASE'] = function(words)
          local upper_words = {}
          for _, w in ipairs(words) do
            table.insert(upper_words, w:upper())
          end
          return table.concat(upper_words, '_')
        end,
        ['lowercase'] = function(words) return table.concat(words, '') end,
        ['UPPERCASE'] = function(words) return table.concat(words, ''):upper() end,
        ['dot.case'] = function(words) return table.concat(words, '.') end,
        ['Title Case'] = function(words)
          local titled = {}
          for _, w in ipairs(words) do
            table.insert(titled, w:sub(1, 1):upper() .. w:sub(2))
          end
          return table.concat(titled, ' ')
        end,
      }
      cc.styles = {
        { text = 'snake_case', example = 'my_variable_name' },
        { text = 'kebab-case', example = 'my-variable-name' },
        { text = 'camelCase', example = 'myVariableName' },
        { text = 'PascalCase', example = 'MyVariableName' },
        { text = 'UPPER_CASE', example = 'MY_VARIABLE_NAME' },
        { text = 'lowercase', example = 'myvariablename' },
        { text = 'UPPERCASE', example = 'MYVARIABLENAME' },
        { text = 'dot.case', example = 'my.variable.name' },
        { text = 'Title Case', example = 'My Variable Name' },
      }
      function cc.convert(style, text) return cc.converters[style](cc.parse_words(text)) end
      function cc.pick_style(text, replace_fn)
        Snacks.picker.select(cc.styles, {
          prompt = 'Choose Naming Style',
          format_item = function(item) return item.text .. ' -> ' .. item.example end,
        }, function(item)
          if not item then return end
          replace_fn(cc.convert(item.text, text))
        end)
      end
      function cc.convert_word()
        local word = vim.fn.expand('<cword>')
        if word == '' then
          vim.notify('no word found', vim.log.levels.WARN)
          return
        end
        cc.pick_style(word, function(converted) vim.cmd('normal! ciw' .. converted) end)
      end
      function cc.convert_selection()
        vim.cmd('normal! gv')
        local start_pos = vim.fn.getpos('v')
        local end_pos = vim.fn.getpos('.')
        local lines = vim.fn.getregion(start_pos, end_pos)
        local text = table.concat(lines, '\n')
        if text == '' then
          vim.notify('no text selected', vim.log.levels.WARN)
          return
        end
        local saved_start, saved_end = start_pos, end_pos
        cc.pick_style(text, function(converted)
          vim.fn.setpos('.', saved_start)
          vim.cmd('normal! v')
          vim.fn.setpos('.', saved_end)
          vim.cmd('normal! c' .. converted)
        end)
      end
      map('n', '<leader>cc', cc.convert_word, { desc = 'Convert naming style (word)' })
      map('v', '<leader>cc', cc.convert_selection, { desc = 'Convert naming style (selection)' })
    end,
  },
}
