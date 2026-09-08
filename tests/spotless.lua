package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

package.preload['conform.formatters.spotless_maven'] = function()
  return { args = function() return { 'spotless:apply' } end }
end

local spotless = require('plugins.format.spotless').spec()
local test_root = vim.fn.tempname()

local function path(...) return vim.fs.joinpath(test_root, ...) end

local function write_file(filename, content)
  vim.fn.mkdir(vim.fs.dirname(filename), 'p')
  assert(vim.fn.writefile(vim.split(content, '\n', { plain = true }), filename) == 0)
end

local function executable_file(filename)
  write_file(filename, '#!/bin/sh')
  assert(vim.fn.setfperm(filename, 'rwx------') == 1)
end

local function buffer_for(filename)
  write_file(filename, '')
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(bufnr, filename)
  return bufnr
end

local function context_for(filename, bufnr) return { filename = filename, dirname = vim.fs.dirname(filename), buf = bufnr } end

local function assert_list(expected, actual)
  assert(#actual == #expected, ('expected %d items, got %d'):format(#expected, #actual))
  for i, value in ipairs(expected) do
    assert(actual[i] == value, ('expected item %d to be %s, got %s'):format(i, value, actual[i]))
  end
end

local function run()
  vim.fn.mkdir(test_root, 'p')

  local maven_root = path('maven')
  local parent_pom = path('maven', 'parent', 'pom.xml')
  local module_pom = path('maven', 'module', 'pom.xml')
  local wrapper = path('maven', 'mvnw')
  write_file(
    parent_pom,
    '<project><build><plugins><plugin><artifactId>spotless-maven-plugin</artifactId><configuration><formats><format><includes><include>**/*.xml</include></includes></format></formats></configuration></plugin></plugins></build></project>'
  )
  write_file(module_pom, '<project><parent><relativePath>../parent/pom.xml</relativePath></parent></project>')
  executable_file(wrapper)

  local java_file = path('maven', 'module', 'src', 'Main.java')
  local java_buf = buffer_for(java_file)
  local java_ctx = context_for(java_file, java_buf)
  assert_list({ 'spotless_maven' }, spotless.by_ft.java(java_buf))
  assert(spotless.formatters.spotless_maven.condition(nil, java_ctx))
  assert(spotless.formatters.spotless_maven.command(nil, java_ctx) == wrapper)
  assert(spotless.formatters.spotless_maven.cwd(nil, java_ctx) == maven_root)
  assert_list({ '-f', module_pom, '-N', 'spotless:apply' }, spotless.formatters.spotless_maven.args({}, java_ctx))

  local xml_file = path('maven', 'module', 'src', 'config.xml')
  local xml_buf = buffer_for(xml_file)
  assert_list({ 'spotless_maven' }, spotless.by_ft.xml(xml_buf))

  local isolated_pom = path('isolated', 'module', 'pom.xml')
  write_file(path('isolated', 'pom.xml'), '<project><build><plugins><plugin><artifactId>spotless-maven-plugin</artifactId></plugin></plugins></build></project>')
  write_file(isolated_pom, '<project><parent><relativePath/></parent></project>')
  local isolated_file = path('isolated', 'module', 'src', 'Main.java')
  local isolated_buf = buffer_for(isolated_file)
  assert_list({ 'clang-format' }, spotless.by_ft.java(isolated_buf))

  local gradle_root = path('gradle')
  executable_file(path('gradle', 'gradlew'))
  write_file(path('gradle', 'app', 'build.gradle.kts'), 'plugins { id("com.diffplug.spotless") }')
  local gradle_file = path('gradle', 'app', 'src', 'Main.java')
  local gradle_buf = buffer_for(gradle_file)
  local gradle_ctx = context_for(gradle_file, gradle_buf)
  assert_list({ 'spotless_gradle' }, spotless.by_ft.java(gradle_buf))
  assert(spotless.formatters.spotless_gradle.condition(nil, gradle_ctx))
  assert(vim.fs.dirname(path('gradle', 'gradlew')) == gradle_root)

  write_file(path('bounded', 'build.gradle'), 'spotless { java {} }')
  executable_file(path('bounded', 'project', 'gradlew'))
  local bounded_file = path('bounded', 'project', 'app', 'src', 'Main.java')
  local bounded_buf = buffer_for(bounded_file)
  local bounded_ctx = context_for(bounded_file, bounded_buf)
  assert_list({ 'clang-format' }, spotless.by_ft.java(bounded_buf))
  assert(not spotless.formatters.spotless_gradle.condition(nil, bounded_ctx))
end

local ok, err = xpcall(run, debug.traceback)
vim.fn.delete(test_root, 'rf')
if not ok then error(err) end

print('spotless tests passed')
