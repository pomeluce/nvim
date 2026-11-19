package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path
vim.opt.rtp:prepend(vim.fn.getcwd())
vim.o.columns = 180
vim.o.lines = 35
local selections = {}
local preparations = {}
package.loaded['configs.java.prepare'] = {
  new = function()
    return {
      prepare = function(_, target, _, callback) preparations[#preparations + 1] = { target = target, callback = callback } end,
      cancel = function() end,
    }
  end,
}
package.loaded['configs.java.picker'] = {
  select = function(items, _, callback) selections[#selections + 1] = { items = items, callback = callback } end,
}
local root = vim.fn.tempname() .. ' java services'
vim.fn.mkdir(root, 'p')
vim.fn.writefile({
  'import java.util.Arrays;',
  'public class Fixture {',
  '  public static void main(String[] args) throws Exception {',
  '    System.out.println("ARGV=" + Arrays.toString(args));',
  '    System.out.flush();',
  '    if (args.length > 0 && args[0].equals("once")) return;',
  '    for (int i = 0; i < 600; i++) {',
  '      System.out.println("TICK=" + i); System.out.flush(); Thread.sleep(100);',
  '    }',
  '  }',
  '}',
}, root .. '/Fixture.java')
local compiled = vim.system({ 'javac', '-d', root, root .. '/Fixture.java' }, { text = true }):wait()
assert(compiled.code == 0, compiled.stderr)
local runner = require('configs.java.runner').new(root, {}, true)
local other = require('configs.java.runner').new(root .. '/other', {}, true)
local function config(args) return { mainClass = 'Fixture', projectName = 'fixture', args = args, javaExec = vim.fn.exepath('java'), classPaths = { root }, cwd = root } end
local function text(run) return table.concat(vim.api.nvim_buf_get_lines(run.buf, 0, -1, false), '\n') end
local function await(predicate, message) assert(vim.wait(5000, predicate, 10), message) end
local function scenario()
  assert(runner:run(config({ 'start', '', 'demo service', '$HOME', ';' })) == 'started')
  local start = runner.current
  await(function() return text(start):find('ARGV=[start, , demo service, $HOME, ;]', 1, true) end, 'program arguments did not reach a real Main unchanged')
  assert(runner:run(config('stop')) == 'started')
  local stop = runner.current
  assert(start ~= stop and start.job_id and stop.job_id, 'different arguments must create independent processes')
  assert(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(start.buf), ':t') == 'Fixture', 'log buffer display names must contain only the Main name')
  assert(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(stop.buf), ':t') == 'Fixture')
  assert(vim.api.nvim_buf_get_name(start.buf) ~= vim.api.nvim_buf_get_name(stop.buf), 'same-Main buffers still need unique internal names')
  assert(runner:run(config('"stop"')) == 'skipped', 'equivalent argv must identify the same running instance')
  assert(#runner.run_order == 2 and start.job_id, 'launching stop must not kill start')
  await(function() return text(stop):find('ARGV=[stop]', 1, true) end, 'second process did not start')

  runner:select_log(start)
  local bar = vim.wo[runner.log_win].winbar
  assert(bar:find(('%%%d@v:lua.JavaRunnerLogClick@'):format(start.buf * 2 + 1), 1, true), 'each visible tab must have a close click target')
  _G.JavaRunnerLogClick(start.buf * 2 + 1, 1, 'l', '')
  await(function() return start.hidden end, 'close click did not hide running log')
  assert(start.job_id and runner.current == stop and vim.api.nvim_buf_is_valid(start.buf))
  local hidden_output = text(start)
  await(function() return text(start) ~= hidden_output end, 'hidden logs stopped receiving output')
  runner:open_log()
  local picker = selections[#selections]
  assert(#picker.items == 2)
  picker.callback({ start })
  assert(not start.hidden and runner.current == start)

  assert(other:run(config({ 'other' })) == 'started')
  local other_run = other.current
  runner:stop_selected({ runner:stop_candidates()[1] })
  await(function() return not start.job_id end, 'selective stop did not terminate selected process')
  assert(stop.job_id and other_run.job_id, 'selective stop affected another service or project')
  runner:close_log(start)
  assert(not vim.api.nvim_buf_is_valid(start.buf), 'closing an exited log must release its buffer')
  _G.JavaRunnerLogClick(start.buf * 2 + 1, 1, 'l', '')
  vim.wait(20)

  runner:close_log(stop)
  assert(stop.hidden and stop.job_id and runner.current == nil)
  runner:stop_all()
  await(function() return not stop.job_id end, 'StopAll missed a service with a hidden log')
  assert(vim.api.nvim_buf_is_valid(stop.buf), 'hidden logs must survive service exit')
  assert(other_run.job_id, 'StopAll crossed project boundaries')
  runner:toggle()
  picker = selections[#selections]
  picker.callback({ stop })
  assert(runner.current == stop and not stop.hidden)
  runner:close_log(stop)
  assert(not vim.api.nvim_buf_is_valid(stop.buf) and #runner.run_order == 0)

  -- Rerunning an exited and closed instance must not leave a duplicate tab.
  runner:run(config({ 'once' }))
  local once = runner.current
  await(function() return not once.job_id end, 'short-lived Main did not exit')
  runner:close_log(once)
  runner:run(config({ 'once' }))
  await(function() return not runner.current.job_id end)
  assert(#runner.run_order == 1)

  -- A stop picker may remain open while a selected queued target becomes a process.
  runner:launch(config({ 'queued' }), vim.api.nvim_get_current_buf())
  local candidate = runner:stop_candidates()[1]
  assert(candidate.tasks and not candidate.run, 'fixture must capture a queued target')
  preparations[1].callback(nil, preparations[1].target)
  assert(runner.current.job_id, 'fixture must start the selected target before stop confirmation')
  runner:stop_selected({ candidate })
  await(function() return not runner.current.job_id end)

  -- External buffer deletion must not lose process tracking or break output callbacks.
  runner:run(config({ 'wipe' }))
  local wiped = runner.current
  vim.api.nvim_buf_delete(wiped.buf, { force = true })
  runner:valid_run_order()
  assert(wiped.job_id and #runner:stop_candidates() == 1)
  runner:stop_all()
  await(function() return not wiped.job_id end, 'buffer deletion lost service management')
end
local ok, err = xpcall(scenario, debug.traceback)
runner:stop_all()
other:stop_all()
vim.wait(5000, function()
  for _, current_runner in ipairs({ runner, other }) do
    for _, run in pairs(current_runner.runs) do
      if run.job_id then return false end
    end
  end
  return true
end, 10)
vim.fn.delete(root, 'rf')
assert(ok, err)
print('java runner real process tests passed')
