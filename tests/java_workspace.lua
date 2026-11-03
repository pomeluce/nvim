package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

local root = vim.fn.tempname()
vim.fn.mkdir(root .. '/app/src', 'p')
vim.fn.writefile({ '<project/>' }, root .. '/pom.xml')
vim.fn.writefile({ 'class Main {}' }, root .. '/app/src/Main.java')
local workspace = require('configs.java.workspace').new(root)
local buf = vim.api.nvim_get_current_buf()
local stopped, started, attached, original_status = 0, 0, {}, 0
local clients = {}
local config
local old = {
  id = 1,
  attached_buffers = { [buf] = true },
  config = { name = 'jdtls', root_dir = root, handlers = { ['language/status'] = function() original_status = original_status + 1 end } },
  stop = function() stopped = stopped + 1 end,
}
clients[1] = old
local original_get = vim.lsp.get_client_by_id
local original_start = vim.lsp.start
local original_attach = vim.lsp.buf_attach_client
local original_notify = vim.notify
vim.notify = function() end
vim.lsp.get_client_by_id = function(id) return clients[id] end
vim.lsp.start = function(options)
  started = started + 1
  config = options
  clients[2] = { id = 2, config = options, attached_buffers = old.attached_buffers, stop = old.stop }
  return 2
end
vim.lsp.buf_attach_client = function(b, id) attached[b] = id end

local completed = 0
local function success(err)
  assert(not err, err and err.message)
  completed = completed + 1
end
workspace:sync(old, buf, success)
assert(completed == 1 and stopped == 0, 'unchanged workspaces must reuse JDTLS')
vim.fn.writefile({ 'class Main { int x; }' }, root .. '/app/src/Main.java')
workspace:sync(old, buf, success)
assert(completed == 2 and stopped == 0, 'ordinary source edits must not restart JDTLS')
vim.fn.mkdir(root .. '/target/generated', 'p')
vim.fn.writefile({ 'class Generated {}' }, root .. '/target/generated/Generated.java')
workspace:sync(old, buf, success)
assert(completed == 3 and stopped == 0, 'generated output must not trigger restart loops')

vim.fn.writefile({ '<project><modules><module>app</module></modules></project>' }, root .. '/pom.xml')
local original_timer = vim.uv.new_timer
vim.uv.new_timer = function() return nil end
local allocation_error
workspace:sync(old, buf, function(err) allocation_error = err end)
vim.uv.new_timer = original_timer
assert(allocation_error and allocation_error.kind == 'refresh', 'timer allocation failure must report a refresh error')
assert(stopped == 0, 'timer allocation failure must leave the existing language server running')
workspace:sync(old, buf, success)
workspace:sync(nil, buf, success)
assert(stopped == 1 and completed == 3, 'changed POMs must wait for one shared restart')
vim.wait(60)
assert(started == 0, 'must wait for actual process exit, not is_stopped()')
clients[1] = nil
assert(vim.wait(500, function() return started == 1 end), 'replacement server did not start')
assert(attached[buf] == 2 and completed == 3, 'buffers must reattach before launch resumes')
config.handlers['language/status'](nil, { type = 'Starting' }, { client_id = 2 })
assert(completed == 3, 'launch must wait for workspace initialization')
config.handlers['language/status'](nil, { type = 'ServiceReady' }, { client_id = 2 })
assert(completed == 5 and original_status == 2, 'all waiters and original handlers must run')
workspace:sync(clients[2], buf, success)
assert(completed == 6 and stopped == 1, 'successful refresh must update the structure snapshot')

vim.fn.writefile({ 'class Extra {}' }, root .. '/app/src/Extra.java')
local failure
workspace:sync(clients[2], buf, function(err) failure = err end)
clients[2] = nil
assert(vim.wait(500, function() return started == 2 end), 'new source files must trigger workspace refresh')
config.handlers['language/status'](nil, { type = 'ERROR' }, { client_id = 2 })
assert(failure and failure.kind == 'refresh', 'failed imports must prevent launch')

vim.lsp.get_client_by_id = original_get
vim.lsp.start = original_start
vim.lsp.buf_attach_client = original_attach
vim.notify = original_notify
vim.fn.delete(root, 'rf')
print('java workspace tests passed')
