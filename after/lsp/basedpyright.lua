---@type vim.lsp.Config
return {
  root_markers = { 'pyproject.toml', 'main.py', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', 'pyrightconfig.json', '.git' },
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = 'standard',
        autoImportCompletions = true, -- 开启自动导入补全
        indexing = true, -- 强制索引工作区文件
        autoSearchPaths = true, -- 自动将项目子路径添加到搜索路径
        useLibraryCodeForTypes = true, -- 对第三方库进行类型推断
        disableOrganizeImports = true, -- 禁用自动导入排序
        ignorePatterns = { '*.pyi', '**/__pycache__/**', '**/node_modules/**' }, -- 文件忽略模式

        diagnosticMode = 'openFilesOnly', -- 只对打开的文件报错
        diagnosticSeverityOverrides = {
          reportMissingTypeStubs = 'none', -- 忽略没有类型提示的第三方库的警告
          reportUnreachable = 'warning', -- 对永远执行不到的代码进行警告
          reportUnusedCoroutine = 'warning', -- 对 async 函数调用时未添加 await 进行警告
          reportUnknownMemberType = 'none', -- 忽略调用对象属性时未知类型警告
          -- reportCallIssue = 'none', -- 函数调用问题检查
        },
      },
    },
  },
}
