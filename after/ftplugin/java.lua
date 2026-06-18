local map = vim.keymap.set

-- 一次性加载插件依赖
PackUtils.load({ name = 'nvim-jdtls' })

-- 每个 Java buffer 都执行 setup（内部自动区分首次/后续）
local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle', 'build.gradle.kts' }
local root_dir = vim.fs.root(0, root_markers) or vim.fn.getcwd()
if vim.fn.executable('jdtls') ~= 1 then return end
require('configs.java').setup(root_dir)

-- 快捷键 — <cmd> 调用命令
local function setup_keymaps(bufnr)
  map('n', '<leader>jc', '<cmd>JavaCompile<cr>', { buffer = bufnr, desc = 'Java: Compile' })
  map('n', '<leader>ju', '<cmd>JavaUpdateConfig<cr>', { buffer = bufnr, desc = 'Java: Update Config' })
  map('n', '<leader>jr', '<cmd>JavaRunMain<cr>', { buffer = bufnr, desc = 'Java: Run Main Class' })
  map('n', '<leader>js', '<cmd>JavaStopMain<cr>', { buffer = bufnr, desc = 'Java: Stop Main Class' })
  map('n', '<leader>jl', '<cmd>JavaToggleLogs<cr>', { buffer = bufnr, desc = 'Java: Toggle Logs' })
  map('n', '<leader>jd', '<cmd>JavaDebugMain<cr>', { buffer = bufnr, desc = 'Java: Debug Main Class' })
  map('n', '<leader>jtc', '<cmd>JavaTestClass<cr>', { buffer = bufnr, desc = 'Java: Test Class' })
  map('n', '<leader>jtm', '<cmd>JavaTestMethod<cr>', { buffer = bufnr, desc = 'Java: Test Method' })
end
setup_keymaps(vim.fn.bufnr())
