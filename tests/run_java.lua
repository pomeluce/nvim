local script = debug.getinfo(1, 'S').source:sub(2)
local root = vim.fs.dirname(vim.fs.dirname(vim.fs.abspath(script)))
local artifacts = vim.fn.tempname()
vim.fn.mkdir(artifacts, 'p')
local failed = false
for _, path in ipairs(vim.fn.glob(root .. '/tests/java_*.lua', false, true)) do
  local name = vim.fs.basename(path)
  local result = vim
    .system({
      vim.v.progpath,
      '--headless',
      '-u',
      'NONE',
      '--cmd',
      'lua vim.opt.rtp:prepend(' .. vim.inspect(root) .. ')',
      '-l',
      path,
    }, { cwd = root, text = true, env = { NVIM_LOG_FILE = artifacts .. '/' .. name .. '.log', XDG_STATE_HOME = artifacts .. '/state' } })
    :wait()
  print(name .. (result.code == 0 and ': PASS' or ': FAIL'))
  if result.code ~= 0 then
    failed = true
    print(result.stdout .. result.stderr)
  end
end
if failed then
  print('Test artifacts retained at ' .. artifacts)
else
  vim.fn.delete(artifacts, 'rf')
end
vim.cmd('cquit ' .. (failed and 1 or 0))
