package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path
vim.opt.rtp:prepend(vim.fn.getcwd())
local options
_G.Snacks = { picker = function(config) options = config end }
local Picker = require('configs.java.picker')
local items = { { label = 'one' }, { label = 'two' }, { label = 'three' } }
local result, callbacks = nil, 0
local function open()
  Picker.select(items, { prompt = 'Java', multiple = true, format_item = function(item) return item.label end }, function(selected)
    result = selected
    callbacks = callbacks + 1
  end)
end
open()
assert(options.items[1].text == 'one')
options.confirm({
  selected = function(_, config)
    assert(config.fallback, 'Enter without selection must use the current item')
    return { { idx = 3 }, { idx = 1 } }
  end,
  close = function() options.on_close() end,
})
assert(vim.wait(1000, function() return callbacks == 1 end))
assert(result[1] == items[1] and result[2] == items[3], 'selection must preserve original order and object identity')
open()
options.on_close()
assert(vim.wait(1000, function() return callbacks == 2 end))
assert(result == nil, 'closing the picker must cancel once')
options.on_close()
vim.wait(20)
assert(callbacks == 2)

Picker.select(items, {
  prompt = 'Java',
  multiple = true,
  format_item = function(item) return item.label end,
  describe_item = function(item) return { name = item.label, package_name = 'example.services', project = 'service-module', args = 'start --instance blue', status = 'running' } end,
}, function() end)
local parts = options.format(options.items[1])
local rendered = table.concat(vim.tbl_map(function(part) return part[1] end, parts))
assert(rendered:find('one%s+:%s+example%.services'), 'picker must display Main name before its package')
assert(parts[2][2] ~= parts[4][2], 'Main name and package must have different visual emphasis')
assert(rendered:find('start --instance blue', 1, true), 'service selection must retain arguments to distinguish instances')
assert(options.items[1].text:find('service-module', 1, true), 'modules must remain searchable')

local single
Picker.select(items, { prompt = 'Java', format_item = function(item) return item.label end }, function(selected) single = selected end)
options.confirm({
  current = function() return options.items[2] end,
  selected = function() error('single selection must not use multiple selected entries') end,
  close = function() options.on_close() end,
})
assert(vim.wait(1000, function() return single ~= nil end))
assert(#single == 1 and single[1] == items[2], 'the styled single picker must return the focused original item')

local original_columns = vim.o.columns
vim.o.columns = 240
local function picker_width(name, args, limit)
  Picker.select({ { name = name, package_name = 'example', args = args } }, {
    prompt = 'Java',
    max_width = limit,
    format_item = function(item) return item.name end,
    describe_item = function(item) return item end,
  }, function() end)
  return options.layout.layout.width()
end
local short_width = picker_width('App')
local medium_width = picker_width('MaintenanceApplication')
local long_width = picker_width(string.rep('Application', 30))
assert(short_width < medium_width and medium_width < long_width, 'picker width must shrink and grow with visible content')
assert(long_width <= 120, 'long entries must respect the default maximum width')
assert(picker_width('App', string.rep('argument', 30), 70) == 70, 'argument details must count toward width and respect the configured maximum')
assert(picker_width(string.rep('服', 12)) > picker_width(string.rep('A', 12)), 'width must use display columns rather than bytes or character count')
picker_width(string.rep('Application', 30))
vim.o.columns = 60
assert(options.layout.layout.width() <= 56, 'an open picker must adapt to a narrower editor')

vim.o.columns = 240
local aligned = {
  { name = 'App', package_name = 'example.short' },
  { name = 'MediumApplication', package_name = 'example.medium' },
  { name = string.rep('VeryLongApplication', 5), package_name = 'example.long' },
  { name = '中文Main名称', package_name = 'example.unicode' },
}
Picker.select(aligned, {
  prompt = 'Java',
  format_item = function(item) return item.name end,
  describe_item = function(item) return item end,
}, function() end)
local colon_column
for _, entry in ipairs(options.items) do
  local text = table.concat(vim.tbl_map(function(part) return part[1] end, options.format(entry)))
  local colon = assert(text:find(' : ', 1, true))
  local column = vim.fn.strdisplaywidth(text:sub(1, colon - 1))
  colon_column = colon_column or column
  assert(column == colon_column, 'package separators must align for different Main lengths and Unicode')
end
local long_parts = options.format(options.items[3])
assert(long_parts[2][1]:find('...', 1, true), 'overlong Main names must show an ellipsis')
assert(vim.fn.strdisplaywidth(long_parts[2][1]) <= 32)
assert(options.items[3].text:find(aligned[3].name, 1, true), 'truncated names must remain fully searchable')
local selected_aligned
-- The selected finder index must continue to resolve to the complete original Main.
Picker.select(aligned, {
  prompt = 'Java',
  format_item = function(item) return item.name end,
  describe_item = function(item) return item end,
}, function(selected) selected_aligned = selected end)
options.confirm({ current = function() return options.items[3] end, close = function() options.on_close() end })
assert(vim.wait(1000, function() return selected_aligned ~= nil end))
assert(selected_aligned[1] == aligned[3])
vim.o.columns = original_columns
print('java picker tests passed')
