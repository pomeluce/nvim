local map = vim.keymap.set

vim.api.nvim_create_autocmd('FileType', {
  once = true,
  pattern = { 'http', 'rest', 'javascript', 'lua' },
  callback = function()
    PackUtils.load({ name = 'kulala.nvim' }, function()
      local kulala = require('kulala')
      local ui = require('kulala.ui')
      local ws = require('kulala.cmd.websocket')
      kulala.setup({
        kulala_core = { path = vim.fn.exepath('kulala-core') },
        ui = {
          split_direction = 'horizontal',
          win_opts = { width = 80, height = 18 },
        },
        lsp = {
          enable = true,
          filetypes = { 'http', 'rest', 'json', 'yaml', 'bruno' },
          keymaps = false,
        },
        global_keymaps = false,
        kulala_keymaps = {
          ['Previous tab'] = { '<s-tab>', ui.show_previous_tab, mode = { 'n' } },
          ['Next tab'] = { '<tab>', ui.show_next_tab, mode = { 'n' } },
          ['Show headers'] = { 'H', ui.show_headers },
          ['Show body'] = { 'B', ui.show_body },
          ['Show headers and body'] = { 'A', ui.show_headers_body },
          ['Show verbose'] = { 'V', ui.show_verbose },
          ['Show script output'] = { 'O', ui.show_script_output },
          ['Show stats'] = { 'S', ui.show_stats },
          ['Show report'] = { 'R', ui.show_report },
          ['Show filter'] = { 'F', ui.toggle_filter },
          ['Next response'] = { ']', ui.show_next, prefix = false },
          ['Previous response'] = { '[', ui.show_previous, prefix = false },
          ['Jump to response'] = {
            '<CR>',
            ui.keymap_enter,
            mode = { 'n', 'v' },
            desc = 'also: Update filter and Send WS message for WS connections',
            prefix = false,
          },
          ['Clear responses history'] = { 'X', ui.clear_responses_history },
          ['Send WS message'] = { '<S-CR>', ws.send, mode = { 'n', 'v' }, prefix = false },
          ['Interrupt requests'] = {
            '<C-c>',
            ui.interrupt_requests,
            desc = 'also: CLose WS connection',
            prefix = false,
          },
          ['Show help'] = { '?', ui.show_help, prefix = false },
          ['Show news'] = { 'g?', ui.show_news, prefix = false },
          ['Toggle split/float'] = { '|', ui.toggle_display_mode, prefix = false },
          ['Close'] = { 'q', ui.close_kulala_buffer, prefix = false },
        },
      })

      map({ 'n', 'v' }, '<C-CR>', kulala.run, { desc = 'Send request' })
      map({ 'n', 'v' }, '<leader>Rs', kulala.run, { desc = 'Send request' })
      map({ 'n', 'v' }, '<leader>Ra', kulala.run_all, { desc = 'Send all requests' })
      map({ 'n', 'v' }, '<leader>Rb', kulala.scratchpad, { desc = 'Open scratchpad' })
    end)
  end,
})
