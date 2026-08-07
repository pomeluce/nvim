local bufnr = vim.api.nvim_get_current_buf()
local actions = require('configs.java.actions')

-- jdtls class files are transient views, not project source buffers.
if actions.attach_classfile(bufnr) then return end

PackUtils.load({ name = 'nvim-jdtls' })
if vim.fn.executable('jdtls') ~= 1 then
  vim.notify_once('jdtls is not executable; Java LSP support is disabled', vim.log.levels.WARN)
  return
end

local markers = {
  '.git',
  'mvnw',
  'gradlew',
  'pom.xml',
  'settings.gradle',
  'settings.gradle.kts',
  'build.gradle',
  'build.gradle.kts',
}
local root_dir = vim.fs.root(bufnr, markers) or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
local java = require('configs.java').setup(root_dir)
actions.attach(bufnr, java)
