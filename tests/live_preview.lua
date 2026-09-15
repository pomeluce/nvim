-- Run with: nvim --headless -u NONE -i NONE -l tests/live_preview.lua
-- LIVE_PREVIEW_PLUGIN can point to a separate live-preview.nvim checkout.
package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path
local plugin = vim.env.LIVE_PREVIEW_PLUGIN or (vim.fn.stdpath('data') .. '/site/pack/core/opt/live-preview.nvim')
assert(vim.fn.isdirectory(plugin) == 1, 'live-preview.nvim must be installed to run this regression test')
vim.opt.rtp:append(plugin)

_G.PackUtils = {
  load = function(spec, configure)
    assert(spec.name == 'live-preview.nvim')
    vim.cmd.runtime('plugin/livepreview.lua')
    if configure then configure() end
    return true
  end,
}
dofile('lua/plugins/tools/live-preview.lua')
vim.api.nvim_exec_autocmds('VimEnter', {})

local Watcher = require('livepreview.server.fswatch').Watcher
local livepreview = require('livepreview')
local root = vim.fn.tempname()
vim.fn.mkdir(root .. '/child', 'p')
local handles = {}
local function remember(watcher)
  if watcher.watcher then handles[#handles + 1] = watcher.watcher end
  for _, child in ipairs(watcher.children) do
    remember(child)
  end
  return watcher
end

local ok, err = xpcall(function()
  local watcher = Watcher:new(root)
  watcher:start(function() end)
  remember(watcher)
  assert(#watcher.children == 1)
  assert(vim.uv.fs_rmdir(root .. '/child'))
  assert(vim.wait(1000, function() return watcher.children[1].watcher == nil end, 10), 'directory deletion was not observed')
  watcher:close()
  for _, handle in ipairs(handles) do
    assert(handle:is_closing(), 'deleted directory shutdown leaked a watcher')
  end
  watcher:close()

  -- A missing or closing parent handle must not prevent descendant cleanup.
  for _, state in ipairs({ 'missing', 'closing', 'active' }) do
    local parent = Watcher:new(root)
    local child = Watcher:new(root)
    local grandchild = Watcher:new(root)
    parent.children = { child }
    child.children = { grandchild }
    remember(parent)
    if state ~= 'active' then parent.watcher:close() end
    if state == 'missing' then parent.watcher = nil end
    parent:close()
    parent:close()
    for _, handle in ipairs(handles) do
      assert(handle:is_closing(), state .. ' parent left an open handle')
    end
  end

  -- Exercise the command -> public API -> server -> recursive watcher chain.
  for _ = 1, 2 do
    vim.fn.mkdir(root .. '/child', 'p')
    local server = require('livepreview.server').Server:new(root)
    livepreview.serverObj = server
    server:start('127.0.0.1', 0, { on_events = { LivePreviewDirChanged = function() end } })
    local listener = server.server
    local address, bind_err = listener:getsockname()
    assert(address, 'server did not bind a port: ' .. tostring(bind_err))
    assert(address.port > 0, 'server did not bind a port')
    local tree = remember(server._watcher)
    assert(vim.uv.fs_rmdir(root .. '/child'))
    assert(vim.wait(1000, function() return tree.children[1].watcher == nil end, 10), 'server did not observe deletion')
    vim.cmd('LivePreview close')
    assert(livepreview.serverObj == nil, 'public API retained the stopped server')
    assert(server._watcher == nil, 'server retained its watcher tree')
    assert(listener:is_closing(), 'server listener was not closed')
    assert(vim.fn.exists('#LivePreview') == 0, 'server autocommands were not removed')
    for _, handle in ipairs(handles) do
      assert(handle:is_closing(), 'server shutdown leaked a watcher')
    end
    vim.cmd('LivePreview close')
    assert(vim.wait(1000, function() return server.server == nil end, 10), 'listener close callback did not run')
  end
end, debug.traceback)

for _, handle in ipairs(handles) do
  if not handle:is_closing() then handle:close() end
end
if livepreview.serverObj and not livepreview.serverObj.server:is_closing() then livepreview.serverObj.server:close() end
livepreview.serverObj = nil
vim.fn.delete(root, 'rf')
assert(ok, err)
print('live-preview tests passed')
