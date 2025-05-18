local M = {}

function M.config()
  -- do nothing
end

function M.setup(actions)
  dofile(vim.g.base46_cache .. 'telescope')

  return {
    defaults = {
      prompt_prefix = ' ',
      selection_caret = ' ',
      path_display = { 'smart' },
      vimgrep_arguments = vim.list_extend(
        { 'rg', '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case', '--hidden' },
        require('akirc').file.search.grep_args
      ),
      sorting_strategy = 'ascending',
      layout_config = {
        horizontal = {
          prompt_position = 'top',
          preview_width = 0.55,
          results_width = 0.8,
        },
        vertical = {
          mirror = false,
        },
        width = 0.7,
        height = 0.65,
        preview_cutoff = 120,
      },
      mappings = {
        i = {
          -- 切换历史搜索
          ['<C-n>'] = actions.cycle_history_next,
          ['<C-p>'] = actions.cycle_history_prev,
          -- 文件移动
          ['<C-j>'] = actions.move_selection_next,
          ['<C-k>'] = actions.move_selection_previous,
          ['<Down>'] = actions.move_selection_next,
          ['<Up>'] = actions.move_selection_previous,
          -- 关闭窗口
          ['<leader>c'] = actions.close,
          -- 打开文件
          ['<CR>'] = actions.select_default,
          ['<C-x>'] = actions.select_horizontal,
          ['<C-v>'] = actions.select_vertical,
          ['<C-t>'] = actions.select_tab,
          -- 预览窗口移动
          ['<C-u>'] = actions.preview_scrolling_up,
          ['<C-d>'] = actions.preview_scrolling_down,
          -- 文件窗口移动
          ['<PageUp>'] = actions.results_scrolling_up,
          ['<PageDown>'] = actions.results_scrolling_down,
          -- qflist
          ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
          ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
          ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
          ['<M-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
          ['<C-l>'] = actions.complete_tag,
          -- wichkey
          ['<C-_>'] = actions.which_key, -- keys from pressing <C-/>
        },
        n = {
          ['<esc>'] = actions.close,
          ['<CR>'] = actions.select_default,
          ['<C-x>'] = actions.select_horizontal,
          ['<C-v>'] = actions.select_vertical,
          ['<C-t>'] = actions.select_tab,
          ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
          ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
          ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
          ['<M-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
          ['j'] = actions.move_selection_next,
          ['k'] = actions.move_selection_previous,
          ['H'] = actions.move_to_top,
          ['M'] = actions.move_to_middle,
          ['L'] = actions.move_to_bottom,
          ['<Down>'] = actions.move_selection_next,
          ['<Up>'] = actions.move_selection_previous,
          ['gg'] = actions.move_to_top,
          ['G'] = actions.move_to_bottom,
          ['<C-u>'] = actions.preview_scrolling_up,
          ['<C-d>'] = actions.preview_scrolling_down,
          ['<PageUp>'] = actions.results_scrolling_up,
          ['<PageDown>'] = actions.results_scrolling_down,
          ['?'] = actions.which_key,
        },
      },
    },
    pickers = {
      find_files = { hidden = true },
      oldfiles = { theme = 'dropdown' },
      git_status = { theme = 'dropdown' },
    },
    extensions = {
      media_files = {
        -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
        filetypes = { 'png', 'webp', 'jpg', 'jpeg', 'pdf', 'mp4' },
        find_cmd = 'rg',
      },
      fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = 'smart_case', -- or "ignore_case" or "respect_case", the default case_mode is "smart_case"
      },
      ['ui-select'] = {
        require('telescope.themes').get_dropdown {},
      },
      aerial = {
        -- Set the width of the first two columns (the second is relevant only when show_columns is set to 'both')
        col1_width = 2,
        col2_width = 30,
        -- How to format the symbols
        format_symbol = function(symbol_path, filetype)
          if filetype == 'json' or filetype == 'yaml' then
            return table.concat(symbol_path, '.')
          else
            return symbol_path[#symbol_path]
          end
        end,
        -- Available modes: symbols, lines, both
        show_columns = 'both',
      },
    },
  }
end

return M
