local autoGroup = vim.api.nvim_create_augroup('autoGroup', { clear = true })
local autocmd = vim.api.nvim_create_autocmd

-- user event that loads after UIEnter + only if file buf is there
autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("NvFilePost", { clear = true }),
  callback = function(args)
    local file = vim.api.nvim_buf_get_name(args.buf)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })

    if not vim.g.ui_entered and args.event == "UIEnter" then
      vim.g.ui_entered = true
    end

    if file ~= "" and buftype ~= "nofile" and vim.g.ui_entered then
      vim.api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })
      vim.api.nvim_del_augroup_by_name "NvFilePost"

      vim.schedule(function()
        vim.api.nvim_exec_autocmds("FileType", {})

        if vim.g.editorconfig then
          require("editorconfig").config(args.buf)
        end
      end)
    end
  end,
})

-- 修改 lua/packinit.lua 自动更新插件
autocmd('BufWritePost', {
  group = autoGroup,
  callback = function()
    local current_file = vim.fn.expand('%')
    local config_folder = vim.fn.expand('lua/user/plugins/')
    if vim.fn.stridx(current_file, config_folder) == 0 then
      vim.cmd('Lazy sync')
    end
  end,
})

-- 自动切换输入法
autocmd('InsertLeave', {
  group = autoGroup,
  pattern = '*',
  callback = function()
    if vim.api.nvim_get_mode().mode == 'n' then
      vim.fn.system('busctl call --user org.fcitx.Fcitx5 /rime org.fcitx.Fcitx.Rime1 SetAsciiMode b 1')
    end
  end,
})

-- 用 o 换行不要延续注释
autocmd('BufEnter', {
  group = autoGroup,
  pattern = '*',
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions
      - 'o' -- O 和 o, 不要延续注释
      + 'r' -- 回车延续注释
  end,
})

-- 自动安装解析器
autocmd('FileType', {
  group = autoGroup,
  pattern = '*',
  callback = function()
    require('user.configs.tree-sitter').parser_bootstrap()
  end,
})

-- 自动保存折叠信息
autocmd('FileType', {
  group = autoGroup,
  pattern = '*',
  callback = function()
    vim.cmd([[ silent! loadview ]])
  end,
})
autocmd({ 'BufLeave', 'BufWinEnter' }, {
  group = autoGroup,
  pattern = '*',
  callback = function()
    vim.cmd([[ silent! mkview ]])
  end,
})

-- 设置 git 高亮组
local highlightGroup = vim.api.nvim_create_augroup('custom_theme_highlights', { clear = true })
autocmd('BufReadPost', {
  group = highlightGroup,
  pattern = '*',
  callback = function()
    vim.api.nvim_set_hl(0, 'GitSignsAdd', { fg = '#43a047' })
    vim.api.nvim_set_hl(0, 'GitSignsChange', { fg = '#fbc02d' })
    vim.api.nvim_set_hl(0, 'GitSignsDelete', { fg = '#f44336' })
  end,
})
