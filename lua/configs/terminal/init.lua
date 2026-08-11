local tabs = require('configs.terminal.tabs')
local floats = require('configs.terminal.floats')
local runner = require('configs.terminal.run')

-- 稳定门面：调用方无需了解终端功能的内部模块划分。
return {
  toggle_default = tabs.toggle_default,
  toggle_or_prefix = tabs.toggle_or_prefix,
  new_tab = tabs.new_tab,
  close_tab = tabs.close_tab,
  next_tab = tabs.next_tab,
  prev_tab = tabs.prev_tab,
  goto_tab = tabs.goto_tab,
  select_tab = tabs.select_tab,
  rename_tab = tabs.rename_tab,
  toggle_codex = floats.toggle_codex,
  floaterm = floats.floaterm,
  runFile = runner.run_file,
}
