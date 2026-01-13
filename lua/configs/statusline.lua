local utils = require('heirline.utils')
local palette = require('catppuccin.palettes').get_palette('mocha')
local conditions = require('heirline.conditions')

local function get_hl_fg(hl) return vim.api.nvim_get_hl(0, { name = hl }).fg end
local function digits(n)
  n = math.abs(n)
  if n == 0 then return 1 end
  return math.floor(math.log10(n)) + 1
end

local icons = {
  mode = { left = '█', right = '' },
  file = { left = '', right = '' },
  diagnostic = { info = '󰋼 ', warn = ' ', error = ' ', hint = '󰛩 ' },
  cwd = '',
  cur = '',
}

local modes = {
  ['n'] = { 'NORMAL', 'Normal' },
  ['no'] = { 'NORMAL (no)', 'Normal' },
  ['nov'] = { 'NORMAL (nov)', 'Normal' },
  ['noV'] = { 'NORMAL (noV)', 'Normal' },
  ['noCTRL-V'] = { 'NORMAL', 'Normal' },
  ['niI'] = { 'NORMAL i', 'Normal' },
  ['niR'] = { 'NORMAL r', 'Normal' },
  ['niV'] = { 'NORMAL v', 'Normal' },
  ['nt'] = { 'TERMINAL', 'NTerminal' },
  ['ntT'] = { 'TERMINAL (ntT)', 'NTerminal' },

  ['v'] = { 'VISUAL', 'Visual' },
  ['vs'] = { 'V-CHAR (Ctrl O)', 'Visual' },
  ['V'] = { 'V-LINE', 'Visual' },
  ['Vs'] = { 'V-LINE', 'Visual' },
  ['\22'] = { 'V-BLOCK', 'Visual' },
  ['\22s'] = { 'V-BLOCK', 'Visual' },
  ---@diagnostic disable-next-line: duplicate-index
  [''] = { 'V-BLOCK', 'Visual' },

  ['i'] = { 'INSERT', 'Insert' },
  ['ic'] = { 'INSERT (completion)', 'Insert' },
  ['ix'] = { 'INSERT completion', 'Insert' },

  ['t'] = { 'TERMINAL', 'Terminal' },

  ['R'] = { 'REPLACE', 'Replace' },
  ['Rc'] = { 'REPLACE (Rc)', 'Replace' },
  ['Rx'] = { 'REPLACEa (Rx)', 'Replace' },
  ['Rv'] = { 'V-REPLACE', 'Replace' },
  ['Rvc'] = { 'V-REPLACE (Rvc)', 'Replace' },
  ['Rvx'] = { 'V-REPLACE (Rvx)', 'Replace' },

  ['s'] = { 'SELECT', 'Select' },
  ['S'] = { 'S-LINE', 'Select' },
  ---@diagnostic disable-next-line: duplicate-index
  [''] = { 'S-BLOCK', 'Select' },
  ['c'] = { 'COMMAND', 'Command' },
  ['cv'] = { 'COMMAND', 'Command' },
  ['ce'] = { 'COMMAND', 'Command' },
  ['cr'] = { 'COMMAND', 'Command' },
  ['r'] = { 'PROMPT', 'Confirm' },
  ['rm'] = { 'MORE', 'Confirm' },
  ['r?'] = { 'CONFIRM', 'Confirm' },
  ['x'] = { 'CONFIRM', 'Confirm' },
  ['!'] = { 'SHELL', 'Terminal' },
}

local mode_hl = {
  ['Normal'] = palette.blue,
  ['Insert'] = palette.maroon,
  ['Visual'] = palette.lavender,
  ['Select'] = palette.lavender,
  ['Terminal'] = palette.green,
  ['NTerminal'] = palette.yellow,
  ['Confirm'] = palette.peach,
  ['Command'] = palette.red,
}

local lsp_msg = ''

local spinners = { '', '󰪞', '󰪟', '󰪠', '󰪡', '󰪢', '󰪣', '󰪤', '󰪥', '' }
vim.api.nvim_create_autocmd('LspProgress', {
  pattern = { 'begin', 'report', 'end' },
  callback = function(args)
    -- Ensure params exists before accessing its fields
    if not args.data or not args.data.params then return end

    local data = args.data.params.value
    local progress = ''

    if data.percentage then
      local idx = math.max(1, math.floor(data.percentage / 10))
      local icon = spinners[idx]
      progress = icon .. ' ' .. data.percentage .. '%% '
    end

    local loaded_count = data.message and string.match(data.message, '^(%d+/%d+)') or ''
    local str = progress .. (data.title or '') .. ' ' .. (loaded_count or '')
    lsp_msg = data.kind == 'end' and '' or str
    vim.cmd.redrawstatus()
  end,
})

return {
  utils.insert(
    {
      init = function(self)
        self.mode = vim.fn.mode(1)
        self.filename = vim.api.nvim_buf_get_name(0)
      end,
    },
    -- mode
    {
      { provider = icons.mode.left, hl = function(self) return { fg = mode_hl[modes[self.mode][2]] } end },
      {
        provider = function(self) return ' %2(' .. modes[self.mode][1] .. '%)' end,
        hl = function(self) return { fg = palette.base, bg = mode_hl[modes[self.mode][2]], bold = true } end,
      },
      { provider = icons.mode.right, hl = function(self) return { fg = mode_hl[modes[self.mode][2]], bg = palette.surface2 } end },
    },
    -- filename
    {
      { provider = icons.file.left, hl = { fg = palette.surface0, bg = palette.surface2 } },
      {
        init = function(self)
          local name = vim.fn.fnamemodify(self.filename, ':t')
          local micons_present, micons = pcall(require, 'mini.icons')
          if micons_present then
            local ft_icon = micons.get('file', name)
            self.icon = (ft_icon ~= nil and ft_icon) or '󰈚'
          end
        end,
        provider = function(self) return self.icon and (' ' .. self.icon .. ' ') end,
        hl = { fg = palette.overlay2, bg = palette.surface0 },
      },
      {
        provider = function(self)
          local name = vim.fn.fnamemodify(self.filename, ':t')
          if name == '' then return 'Empty ' end
          if not conditions.width_percent_below(#name, 0.25) then name = vim.fn.pathshorten(name) end
          return name .. ' '
        end,
        hl = { fg = palette.overlay2, bg = palette.surface0 },
      },
      { provider = icons.file.right, hl = { fg = palette.surface0 } },
    },
    -- git-branch
    {
      condition = conditions.is_git_repo,
      init = function(self) self.status_dict = vim.b.gitsigns_status_dict end,
      hl = { fg = palette.overlay0 },
      -- branch name
      { provider = function(self) return '  %2(' .. self.status_dict.head .. '%) ' end, hl = { bold = true } },
      {
        provider = function(self)
          local count = self.status_dict.added or 0
          return count > 0 and (' ' .. count .. ' ')
        end,
      },
      {
        provider = function(self)
          local count = self.status_dict.removed or 0
          return count > 0 and (' ' .. count .. ' ')
        end,
      },
      {
        provider = function(self)
          local count = self.status_dict.changed or 0
          return count > 0 and (' ' .. count .. ' ')
        end,
      },
    },
    { provider = '%=' },
    -- lsp_msg
    { provider = function() return vim.o.columns < 120 and '' or lsp_msg end, hl = { fg = palette.rosewater } },
    { provider = '%=' },
    -- diagnostics
    {
      condition = conditions.has_diagnostics,
      static = { ierror = icons.diagnostic.error, iwarn = icons.diagnostic.warn, iinfo = icons.diagnostic.info, ihint = icons.diagnostic.hint },
      init = function(self)
        self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
        self.warns = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
        self.infos = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
      end,
      { provider = function(self) return self.infos > 0 and (self.iinfo .. self.infos .. ' ') end, hl = { fg = get_hl_fg('DiagnosticSignInfo') } },
      { provider = function(self) return self.warns > 0 and (self.iwarn .. self.warns .. ' ') end, hl = { fg = get_hl_fg('DiagnosticSignWarn') } },
      { provider = function(self) return self.errors > 0 and (self.ierror .. self.errors .. ' ') end, hl = { fg = get_hl_fg('DiagnosticError') } },
      { provider = function(self) return self.hints > 0 and (self.ihint .. self.hints .. ' ') end, hl = { fg = get_hl_fg('DiagnosticSignHint') } },
    },
    -- lsp
    {
      conditions = conditions.lsp_attached,
      update = { 'LspAttach', 'LspDetach' },
      provider = function()
        for _, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
          return (vim.o.columns > 100 and '  LSP ~ ' .. client.name .. ' ') or '   LSP '
        end
        return ''
      end,
      hl = { fg = palette.green, bold = true },
    },
    -- 目录
    {
      { provider = icons.cwd, hl = { fg = palette.red } },
      { provider = '󰉋 ', hl = { fg = palette.base, bg = palette.red } },
      {
        conditions = vim.uv.cwd(),
        provider = function()
          local name = vim.uv.cwd()
          return name and ' ' .. (name:match('([^/\\]+)[/\\]*$') or name) .. ' '
        end,
        hl = { fg = palette.overlay2, bg = palette.surface2 },
      },
    },
    -- cursor
    {
      { provider = icons.cur, hl = { fg = palette.peach, bg = palette.surface2 } },
      { provider = '󱉯 ', hl = { fg = palette.base, bg = palette.peach } },
      {
        provider = function()
          local line = vim.fn.line('.')
          local col = vim.fn.charcol('.')
          return string.format('%' .. digits(line) + 1 .. 'd:%-' .. digits(col) + 1 .. 'd', line, col)
        end,
        hl = { fg = palette.overlay2, bg = palette.surface2 },
      },
    }
  ),
}
