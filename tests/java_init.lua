package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path
local root = vim.fn.tempname()
vim.fn.mkdir(root, 'p')
vim.fn.writefile({ '<project><properties><java.version>8</java.version></properties></project>' }, root .. '/pom.xml')
package.loaded.settings = { lsp = { jdtls = { runtimes = { { name = 'JavaSE-1.8', path = '/jdk8' }, { name = 'JavaSE-21', path = '/jdk21', default = true } } } } }
package.loaded['configs.java.runner'] = { new = function() return {} end }
local captured
package.loaded.jdtls = { start_or_attach = function(config) captured = config end, setup_dap = function() end }
require('configs.java').setup(root)
assert(captured.init_options.settings, 'JDK mappings must be sent before project import')
assert(vim.deep_equal(captured.init_options.settings, captured.settings), 'initial and subsequent settings must agree')
assert(captured.init_options.settings.java.configuration.runtimes[1].default == true)
local linked_jdk = root .. '/jdk-link'
vim.fn.mkdir(root .. '/jdk-real', 'p')
assert(vim.uv.fs_symlink(root .. '/jdk-real', linked_jdk))
local resolved = require('configs.java.runtime').project_runtimes(root, { { name = 'JavaSE-1.8', path = linked_jdk } })
assert(resolved[1].path == root .. '/jdk-real', 'JDTLS must receive the resolved JDK installation path')
vim.fn.delete(root, 'rf')
print('java initialization tests passed')
