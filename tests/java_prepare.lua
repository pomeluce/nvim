package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

local commands = {}
local classpath_attempts = 0
local next_request_id = 0
local held_callback
local cancelled_request

local mains = {
  { mainClass = 'example.JobApplication', projectName = 'job' },
  { mainClass = 'example.AuthApplication', projectName = 'auth' },
}

local client = { config = { root_dir = '/workspace' } }
function client:request(method, params, callback)
  assert(method == 'workspace/executeCommand')
  commands[#commands + 1] = params
  next_request_id = next_request_id + 1
  local request_id = next_request_id

  if params.command == 'vscode.java.resolveMainClass' then
    callback(nil, vim.deepcopy(mains))
  elseif params.command == 'vscode.java.buildWorkspace' then
    assert(type(params.arguments) == 'string', 'build arguments must be a JSON string')
    local build = vim.json.decode(params.arguments)
    assert(build.isFullBuild == true, 'launch must rebuild outputs removed by external Maven clean')
    if build.mainClass == 'example.SlowApplication' then
      held_callback = callback
    elseif build.mainClass == 'example.FailedApplication' then
      callback(nil, 0)
    elseif build.mainClass == 'example.BrokenApplication' then
      callback(nil, 2)
    elseif build.mainClass == 'example.UnknownBuildApplication' then
      callback(nil, nil)
    else
      callback(nil, 1)
    end
  elseif params.command == 'vscode.java.resolveClasspath' then
    classpath_attempts = classpath_attempts + 1
    if classpath_attempts < 3 then
      callback({ message = 'Referenced classpath provider does not exist: org.eclipse.m2e.launchconfig.classpathProvider' })
    else
      callback(nil, { { '/workspace/modules' }, { '/workspace/classes', '/workspace/dependency.jar' } })
    end
  elseif params.command == 'vscode.java.resolveJavaExecutable' then
    local java_exec = params.arguments[1] == 'example.ProjectRuntimeApplication' and '/jdk21/bin/java' or '/jdk8/bin/java'
    callback(nil, java_exec)
  elseif params.command == 'vscode.java.checkProjectSettings' then
    assert(type(params.arguments) == 'string', 'project settings arguments must be a JSON string')
    callback(nil, true)
  else
    error('unexpected command: ' .. params.command)
  end
  return true, request_id
end

function client:cancel_request(request_id) cancelled_request = request_id end

local original_get_clients = vim.lsp.get_clients
local original_notify = vim.notify
vim.lsp.get_clients = function() return { client } end
vim.notify = function() end

local function await(callback)
  local result
  callback(function(err, value) result = { err = err, value = value } end)
  assert(vim.wait(3000, function() return result ~= nil end), 'Java preparation did not complete')
  return result
end

local prepare = require('configs.java.prepare').new('/workspace', { { name = 'JavaSE-1.8', path = '/jdk8', default = true } })

local discovered = await(function(done) prepare:discover(0, done) end)
assert(not discovered.err)
assert(#discovered.value == #mains)
assert(discovered.value[1].projectName == 'auth', 'Main targets must have stable project ordering')
assert(discovered.value[1].modulePaths == nil, 'Main discovery must remain lightweight')

local target = vim.deepcopy(discovered.value[1])
local prepared = await(function(done) prepare:prepare(target, 0, done) end)
assert(not prepared.err, prepared.err and prepared.err.message)
assert(prepared.value ~= target, 'launch preparation must not mutate the selected target')
assert(prepared.value.javaExec == '/jdk8/bin/java')
assert(vim.deep_equal(prepared.value.modulePaths, { '/workspace/modules' }))
assert(vim.deep_equal(prepared.value.classPaths, { '/workspace/classes', '/workspace/dependency.jar' }))
assert(prepared.value.vmArgs == '--enable-preview')
assert(classpath_attempts == 3, 'the m2e provider error must get two bounded retries')

local order = vim.tbl_map(function(params) return params.command end, commands)
local expected = {
  'vscode.java.resolveMainClass',
  'vscode.java.buildWorkspace',
  'vscode.java.resolveClasspath',
  'vscode.java.resolveClasspath',
  'vscode.java.resolveClasspath',
  'vscode.java.resolveJavaExecutable',
  'vscode.java.checkProjectSettings',
}
assert(vim.deep_equal(order, expected), 'launch preparation commands ran in an unexpected order')

local project_root = vim.fn.tempname()
vim.fn.mkdir(vim.fs.joinpath(project_root, 'src'), 'p')
vim.fn.writefile({ '<project>', '  <properties><java.version>8</java.version></properties>', '</project>' }, vim.fs.joinpath(project_root, 'pom.xml'))
local java_file = vim.fs.joinpath(project_root, 'src', 'ProjectRuntimeApplication.java')
vim.fn.writefile({ 'class ProjectRuntimeApplication {}' }, java_file)
local java_buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_name(java_buf, java_file)
local project_runtimes = { { name = 'JavaSE-1.8', path = '/jdk8', default = true } }
local runtime = require('configs.java.runtime')
assert(runtime.buffer_version(java_buf) == '8', 'project Java version fixture was not detected')
assert(runtime.java_home(project_runtimes, '8') == '/jdk8', 'Java 8 runtime alias was not mapped')
local project_prepare = require('configs.java.prepare').new(project_root, project_runtimes)
local project_runtime = await(
  function(done) project_prepare:prepare({ mainClass = 'example.ProjectRuntimeApplication', projectName = 'project', cwd = project_root }, java_buf, done) end
)
assert(not project_runtime.err, project_runtime.err and project_runtime.err.message)
assert(project_runtime.value.javaExec == '/jdk8/bin/java', 'project-declared Java 8 must override the JDTLS Java 21 executable')
vim.fn.delete(project_root, 'rf')

local failed = await(function(done) prepare:prepare({ mainClass = 'example.FailedApplication', projectName = 'failed', cwd = '/workspace' }, 0, done) end)
assert(failed.err and failed.err.kind == 'build', 'failed builds must abort launch preparation')

local classpaths_before = classpath_attempts
for _, main_class in ipairs({ 'example.BrokenApplication', 'example.UnknownBuildApplication' }) do
  local broken = await(function(done) prepare:prepare({ mainClass = main_class, projectName = 'broken', cwd = '/workspace' }, 0, done) end)
  assert(broken.err and broken.err.kind == 'build', 'builds with errors or unknown status must abort launch preparation')
  assert(not broken.value, 'unsuccessful builds must not produce a launch configuration')
end
assert(classpath_attempts == classpaths_before, 'unsuccessful builds must not resolve launch classpaths')

local cancelled
prepare:prepare({ mainClass = 'example.SlowApplication', projectName = 'slow', cwd = '/workspace' }, 0, function(err) cancelled = err end)
assert(vim.wait(1000, function() return held_callback ~= nil end), 'slow build request did not start')
assert(prepare:cancel(), 'active launch preparation was not cancelled')
assert(vim.wait(1000, function() return cancelled ~= nil end), 'cancel callback did not run')
assert(cancelled.kind == 'cancelled')
assert(cancelled_request ~= nil, 'active jdtls request was not cancelled')

vim.lsp.get_clients = original_get_clients
vim.notify = original_notify

print('java preparation tests passed')
