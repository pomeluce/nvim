local G = require('G')
local M = {}

function M.config()
  G.g.coc_global_extensions = {
    -- coc 插件市场
    'coc-marketplace',
    -- ts 插件
    'coc-tsserver',
    -- json 插件
    'coc-json',
    -- html css 插件
    'coc-html',
    'coc-css',
    -- vue3 插件
    '@yaegassy/coc-volar',
    '@yaegassy/coc-volar-tools',
    -- lua 插件
    'coc-sumneko-lua',
    -- vim lsp 插件
    'coc-vimlsp',
    -- shell 插件
    'coc-sh',
    -- 数据库插件
    'coc-db',
    -- java 插件
    'coc-java',
    -- python 插件
    'coc-pyright',
    -- prettier 插件
    'coc-prettier',
    -- snippets 插件
    'coc-snippets',
    -- coc 自动匹配扩展
    'coc-pairs',
    -- coc 来源
    'coc-word',
    -- 翻译插件
    'coc-translator',
    -- git 插件
    'coc-git',
  }
  -- Fold 命令折叠缓存区
  G.cmd("command! -nargs=? Fold :call CocAction('fold', <f-args>)")
  -- Format 命令格式化缓冲区
  G.cmd("command! -nargs=0 Format :call CocActionAsync('format')")
  -- OR 命令优化导包
  G.cmd("command! -nargs=0 OR :call CocActionAsync('runCommand', 'editor.action.organizeImport')")
  G.cmd("hi! link CocPum Pmenu")
  G.cmd("hi! link CocMenuSel PmenuSel")
  -- 快捷键配置
  G.map({
    -- 重命名
    { 'n', '<leader>rn', '<Plug>(coc-rename)', { silent = true } },
    -- TODO: goto 跳转
    -- 跳转到定义
    { 'n', 'gd', '<Plug>(coc-definition)', { silent = true } },
    -- 跳转到类型定义
    { 'n', 'gy', '<Plug>(coc-type-definition)', { silent = true } },
    -- 跳转到实现
    { 'n', 'gi', '<Plug>(coc-implementation)', { silent = true } },
    -- 跳转到引用
    { 'n', 'gr', '<Plug>(coc-references)', { silent = true } },
    -- 跳转到错误
    { 'n', 'ge', '<Plug>(coc-diagnostic-next)', { silent = true } },
    -- TODO: 映射函数和类文本对象
    -- 选中 func 内
    { 'x', 'if', '<Plug>(coc-funcobj-i)', { silent = true } },
    { 'o', 'if', '<Plug>(coc-funcobj-i)', { silent = true } },
    -- 选中 func 外
    { 'x', 'af', '<Plug>(coc-funcobj-a)', { silent = true } },
    { 'o', 'af', '<Plug>(coc-funcobj-a)', { silent = true } },
    -- 选中 calss 内
    { 'x', 'ic', '<Plug>(coc-classobj-i)', { silent = true } },
    { 'o', 'ic', '<Plug>(coc-classobj-i)', { silent = true } },
    -- 选中 calss 外
    { 'x', 'ac', '<Plug>(coc-classobj-a)', { silent = true } },
    { 'o', 'ac', '<Plug>(coc-classobj-a)', { silent = true } },
    -- TODO: 补全设置
    -- 显示文档
    { 'n', 'K', ':call CocAction("doHover")<cr>', { silent = true } },
    { 'i', '<c-f>', "coc#pum#visible() ? '<c-y>' : '<c-f>'", { silent = true, expr = true } },
    -- 使用 tab 切换补全建议
    { 'i', '<TAB>',
      "coc#pum#visible() ? coc#pum#next(1) : col('.') == 1 || getline('.')[col('.') - 2] =~# '\\s' ? \"\\<TAB>\" : coc#refresh()",
      { noremap = true, silent = true, expr = true } },
    { 'i', '<s-tab>', "coc#pum#visible() ? coc#pum#prev(1) : \"\\<s-tab>\"",
      { noremap = true, silent = true, expr = true } },
    -- 使用 cr 接受补全项或进行格式化通知, <c-g>u 撤销
    { 'i', '<cr>', "coc#pum#visible() ? coc#pum#confirm() : \"\\<c-g>u\\<cr>\\<c-r>=coc#on_enter()\\<cr>\"",
      { noremap = true, silent = true, expr = true } },
    { 'i', '<c-y>', "coc#pum#visible() ? coc#pum#confirm() : '<c-y>'", { noremap = true, silent = true, expr = true } },
    -- TODO: coc 重启配置
    -- 重启 coc
    { 'n', '<F3>', ":silent CocRestart<cr>", { noremap = true, silent = true } },
    -- 关闭/开启 coc
    { 'n', '<F4>', "get(g:, 'coc_enabled', 0) == 1 ? ':CocDisable<cr>' : ':CocEnable<cr>'",
      { noremap = true, silent = true, expr = true } },
    -- TODO: 其他配置
    -- 编辑当前文件类型的 snippet
    { 'n', '<F9>', ":CocCommand snippets.editSnippets<cr>", { noremap = true, silent = true } },
    -- 查看诊断列表
    { 'n', '<c-e>', ":CocList --auto-preview diagnostics<cr>", { silent = true } },
    -- 翻译当前词
    { 'n', 'mm', "<Plug>(coc-translator-p)", { silent = true } },
    { 'v', 'mm', "<Plug>(coc-translator-pv)", { silent = true } },
    -- 上一处修改
    { 'n', '(', "<Plug>(coc-git-prevchunk)", { silent = true } },
    -- 下一处修改
    { 'n', ')', "<Plug>(coc-git-nextchunk)", { silent = true } },
    -- 显示当前行提交记录
    { 'n', 'C',
      "get(b:, 'coc_git_blame', '') ==# 'Not committed yet' ? \"<Plug>(coc-git-chunkinfo)\" : \"<Plug>(coc-git-commit)\"",
      { silent = true, expr = true } },
    -- 开启/关闭 git blame 提示
    { 'n', '\\g',
      ":call coc#config('git.addGBlameToVirtualText',  !get(g:coc_user_config, 'git.addGBlameToVirtualText', 0)) | call nvim_buf_clear_namespace(bufnr(), -1, line('.') - 1, line('.'))<cr>",
      { silent = true } },
    -- 代码折叠
    { 'n', '<leader>zz', ':Fold<cr>', { noremap = true, silent = true } },
    -- TODO: 代码格式化
    -- 格式化选中行
    { 'x', '=', 'CocHasProvider("formatRange") ? "<Plug>(coc-format-selected)" : "="',
      { noremap = true, silent = true, expr = true } },
    -- 格式化当前行
    { 'n', '=', 'CocHasProvider("formatRange") ? "<Plug>(coc-format-selected)" : "="',
      { noremap = true, silent = true, expr = true } },
    -- 格式化缓冲区
    { 'n', '<leader>fm', ':Format<cr>', { noremap = true, silent = true } },
  })
end

function M.setup()
  -- do nothing
end

return M
