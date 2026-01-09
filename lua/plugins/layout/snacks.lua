vim.pack.add({
  { src = 'https://github.com/folke/snacks.nvim' },
})

-- 重新覆盖全局变量, 避免 lsp 警告
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
.______  .____/\ .___ .______  .___     .___ ._____.___ 
:      \ :   /  \: __|: __   \ |   |___ : __|:         |
|   .   ||.  ___/| : ||  \____||   |   || : ||   \  /  |
|   :   ||     \ |   ||   :  \ |   :   ||   ||   |\/   |
|___|   ||      \|   ||   |___\ \      ||   ||___| |   |
    |___||___\  /|___||___|      \____/ |___|      |___|
              \/                                        
                                                        
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

local map = require('utils').map

-- 全局搜索文件
map('n', '<leader>ff', function() Snacks.picker.smart({ hidden = true }) end, { desc = 'Smart file picker' })
-- 查找打开的缓冲区
map('n', '<leader>fb', function() Snacks.picker.buffers({ sort_lastused = true }) end, { desc = 'Find buffer' })
-- 查找最近打开的文件
map('n', '<leader>fo', Snacks.picker.recent, { desc = 'Find recent file' })
-- 全局搜索文本
map('n', '<leader>ft', Snacks.picker.grep, { desc = 'Live grep in files' })
-- 当前 buffer 搜索文本
map('n', '<leader>fT', function() Snacks.picker.lines({ layout = 'dropdown' }) end, { desc = 'Live grep in current buffer' })
-- 在帮助文档中搜索
map('n', '<leader>fh', function() Snacks.picker.help({ layout = 'dropdown' }) end, { desc = 'Find in help' })
-- 查找所有的 Snacks picker 布局
map('n', '<leader>fl', Snacks.picker.picker_layouts, { desc = 'Find snacks picker layouts' })
-- 查找键位映射
map('n', '<leader>fk', function() Snacks.picker.keymaps({ layout = 'dropdown' }) end, { desc = 'Find keymaps with snacks' })
-- 查找图标
map('n', '<leader>fi', function() Snacks.picker.icons({ layout = 'dropdown' }) end, { desc = 'Find icons' })
-- 查找变量引用(不包含声明)
map('n', 'grr', function() Snacks.picker.lsp_references({ include_declaration = false, include_current = true }) end, { desc = 'Find lsp references' })

-- 查找诊断信息
map('n', '<leader>fd', Snacks.picker.diagnostics_buffer, { desc = 'Find diagnostic in current buffer' })

-- 查找高亮信息
map('n', '<leader>fH', Snacks.picker.highlights, { desc = 'Find highlights' })

-- 删除缓冲区
map('n', '<leader>bc', Snacks.bufdelete.delete, { desc = 'Delete buffers' })
-- 删除其他缓冲区
map('n', '<leader>bC', Snacks.bufdelete.other, { desc = 'Delete other buffers' })

-- 切换浮动终端
map({ 'n', 't' }, '<c-t>', Snacks.terminal.toggle, { desc = 'Toggle float termiinal' })
