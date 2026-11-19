local M = {}

---@class JavaPickerDescription
---@field name string
---@field package_name? string
---@field project? string
---@field args? string
---@field status? string
---@field hidden? boolean

---@class JavaPickerOptions
---@field prompt string
---@field multiple? boolean
---@field max_width? integer Maximum content width in columns (default: 120)
---@field format_item fun(item: table): string
---@field describe_item? fun(item: table): JavaPickerDescription

---@class JavaPickerEntry
---@field idx integer
---@field text string
---@field java JavaPickerDescription
---@field show_project? boolean

local status_highlights = {
  running = 'DiagnosticOk',
  preparing = 'DiagnosticInfo',
  queued = 'DiagnosticHint',
  stopping = 'DiagnosticWarn',
  exited = 'Comment',
}

local function name_label(name, width)
  if vim.fn.strdisplaywidth(name) <= width then return name end
  local suffix = string.rep('.', math.min(3, width))
  local prefix = ''
  for index = 1, vim.fn.strchars(name) do
    local candidate = vim.fn.strcharpart(name, 0, index)
    if vim.fn.strdisplaywidth(candidate) > width - #suffix then break end
    prefix = candidate
  end
  return prefix .. suffix
end

---@param entry JavaPickerEntry
---@param name_width integer
local function format_entry(entry, name_width)
  local item = entry.java
  local label = name_label(item.name, name_width)
  local parts = { { ' ', 'Special' }, { label, 'Title' } }
  if item.package_name and item.package_name ~= '' then
    parts[2][1] = label .. string.rep(' ', name_width - vim.fn.strdisplaywidth(label))
    parts[#parts + 1] = { ' : ', 'Comment' }
    parts[#parts + 1] = { item.package_name, 'Comment' }
  end
  if entry.show_project and item.project then parts[#parts + 1] = { '  [' .. item.project .. ']', 'Directory' } end
  if item.status then parts[#parts + 1] = { '  ● ' .. item.status, status_highlights[item.status] or 'Comment' } end
  if item.hidden then parts[#parts + 1] = { '  hidden', 'Comment' } end
  if item.args and item.args ~= '' then parts[#parts + 1] = { '  ' .. item.args, 'Comment' } end
  return parts
end

---@param items table[]
---@param options JavaPickerOptions
---@param callback fun(items?: table[])
function M.select(items, options, callback)
  local snacks = rawget(_G, 'Snacks')
  if not snacks or not snacks.picker then
    if options.multiple then
      vim.notify('Java multi-selection requires Snacks picker', vim.log.levels.ERROR)
      callback(nil)
    else
      vim.ui.select(
        items,
        vim.tbl_extend('force', options, {
          format_item = function(item)
            if not options.describe_item then return options.format_item(item) end
            local description = options.describe_item(item)
            return description.name .. (description.package_name and (': ' .. description.package_name) or '')
          end,
        }),
        function(item) callback(item and { item } or nil) end
      )
    end
    return
  end
  local entries = {}
  local projects = {}
  local longest_name = 1
  for _, item in ipairs(items) do
    local description = options.describe_item and options.describe_item(item) or { name = options.format_item(item) }
    local fields =
      { description.name, description.package_name or '', description.project or '', description.args or '', description.status or '', description.hidden and 'hidden' or '' }
    if description.package_name then fields[#fields + 1] = description.package_name .. '.' .. description.name end
    local text = table.concat(vim.tbl_filter(function(value) return value ~= '' end, fields), ' ')
    entries[#entries + 1] = { idx = #entries + 1, text = text, java = description }
    longest_name = math.max(longest_name, vim.fn.strdisplaywidth(description.name))
    local key = description.name .. '\0' .. (description.package_name or '')
    projects[key] = projects[key] or {}
    projects[key][description.project or ''] = true
  end
  for _, entry in ipairs(entries) do
    local description = entry.java
    entry.show_project = description.project and description.project ~= '' and vim.tbl_count(projects[description.name .. '\0' .. (description.package_name or '')]) > 1
  end
  local confirmed = false
  local title = ' ' .. options.prompt
  local max_width = math.max(1, options.max_width or 120)
  local prefix_width = options.multiple and math.max(vim.fn.strdisplaywidth('● '), vim.fn.strdisplaywidth('○ ')) or 1
  local function name_width()
    local available = math.min(max_width, math.max(vim.o.columns - 4, 1)) - prefix_width - 4 - vim.fn.strdisplaywidth('  : ')
    return math.min(longest_name, 32, math.max(1, math.floor(available * 0.45)))
  end
  local function picker_width()
    local width = math.max(24, vim.fn.strdisplaywidth(' ' .. title .. ' '))
    local column_width = name_width()
    for _, entry in ipairs(entries) do
      local text = table.concat(vim.tbl_map(function(part) return part[1] end, format_entry(entry, column_width)))
      width = math.max(width, vim.fn.strdisplaywidth(text) + prefix_width + 4)
    end
    return math.min(width, max_width, math.max(vim.o.columns - 4, 1))
  end
  snacks.picker({
    title = title,
    prompt = '   ',
    layout = {
      preset = 'select',
      config = function(layout)
        layout.layout[2] = {
          box = 'vertical',
          border = 'hpad',
          { win = 'list', border = 'hpad' },
        }
      end,
      layout = {
        width = picker_width,
        min_width = 1,
        max_width = max_width,
        height = math.min(#items + 4, 20, math.max(vim.o.lines - 6, 4)),
        border = 'rounded',
        title = ' {title} ',
        title_pos = 'center',
        footer = '',
      },
    },
    formatters = { selected = { show_always = options.multiple == true } },
    icons = { ui = { selected = '● ', unselected = '○ ' } },
    items = entries,
    format = function(entry) return format_entry(entry, name_width()) end,
    sort = { fields = { 'idx' } },
    actions = not options.multiple and {
      select_and_next = function(picker) picker:action('list_down') end,
      select_and_prev = function(picker) picker:action('list_up') end,
      select_all = function() end,
    } or nil,
    confirm = function(picker)
      if confirmed then return end
      local selected = options.multiple and picker:selected({ fallback = true }) or { picker:current() }
      table.sort(selected, function(left, right) return left.idx < right.idx end)
      local result = {}
      for _, entry in ipairs(selected) do
        result[#result + 1] = items[entry.idx]
      end
      confirmed = true
      picker:close()
      vim.schedule(function() callback(result) end)
    end,
    on_close = function()
      if not confirmed then
        confirmed = true
        vim.schedule(function() callback(nil) end)
      end
    end,
  })
end

return M
