vim.pack.add({
  { src = 'https://github.com/stevearc/oil.nvim' },
})

function _G.get_oil_winbar()
  local dir = require('oil').get_current_dir()
  if not dir then return vim.api.nvim_buf_get_name(0) end

  local root = vim.fn.finddir('.git', dir .. ';')
  if root ~= '' then
    root = vim.fn.fnamemodify(root, ':h')
  else
    root = vim.loop.cwd() or dir
  end

  local project_name = vim.fn.fnamemodify(root, ':t')

  local dir_path = vim.fn.fnamemodify(dir, ':p')
  local root_path = vim.fn.fnamemodify(root, ':p')
  return dir_path == root_path and project_name or (vim.startswith(dir_path, root_path) and project_name .. '/' .. vim.fn.fnamemodify(dir, ':.' .. root) or dir_path)
end

local detail = false
require('oil').setup({
  default_file_explorer = true,
  keymaps = {
    ['<C-h>'] = false,
    ['<C-l>'] = false,
    ['<C-k>'] = false,
    ['<C-j>'] = false,
    ['g.'] = false,
    ['<ESC>'] = { 'actions.close', mode = 'n' },
    ['<leader>c'] = 'actions.close',
    ['<C-r>'] = 'actions.refresh',
    ['H'] = 'actions.toggle_hidden',
    ['\\'] = { 'actions.select', opts = { horizontal = true } },
    ['|'] = { 'actions.select', opts = { vertical = true } },
    ['gd'] = {
      desc = 'Toggle file detail view',
      callback = function()
        detail = not detail
        if detail then
          require('oil').set_columns({ 'icon', 'permissions', 'size', 'mtime' })
        else
          require('oil').set_columns({ 'icon' })
        end
      end,
    },
  },
  win_options = { winbar = '%!v:lua.get_oil_winbar()' },
})
