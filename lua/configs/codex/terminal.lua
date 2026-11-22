local api = vim.api
local M = {}

function M.visible(session)
  if not session.buf or not api.nvim_buf_is_valid(session.buf) then return end
  local tab = api.nvim_get_current_tabpage()
  for _, win in ipairs(vim.fn.win_findbuf(session.buf)) do
    if api.nvim_win_get_tabpage(win) == tab then return win end
  end
end

local function set_winbar(win) vim.wo[win].winbar = "%#Title#%{get(b:, 'codex_instance', 1)}:  Codex CLI%*" end

local function hide_window(session, win)
  local tab = api.nvim_win_get_tabpage(win)
  local previous = session.return_to[tab]
  if win == api.nvim_get_current_win() and previous and api.nvim_win_is_valid(previous) then api.nvim_set_current_win(previous) end
  if not pcall(api.nvim_win_hide, win) then
    vim.wo[win].winfixwidth = false
    vim.wo[win].winbar = ''
    api.nvim_win_set_buf(win, api.nvim_create_buf(true, false))
  end
end

function M.hide(session)
  local win = M.visible(session)
  if win then hide_window(session, win) end
end

function M.send(session, bytes)
  if not session.job then return false end
  local ok, written = pcall(vim.fn.chansend, session.job, bytes)
  return ok and written > 0
end

function M.empty_composer(session)
  local win = M.visible(session)
  if not win or session.status ~= 'idle' then return false end

  -- Look at the active terminal screen, rather than a prompt in scrollback.
  -- Keep context queued when Codex draws a picker, a modal or an unfamiliar prompt.
  local last = api.nvim_buf_line_count(session.buf)
  local first = math.max(0, last - api.nvim_win_get_height(win))
  local lines = api.nvim_buf_get_lines(session.buf, first, last, false)
  while #lines > 0 and vim.trim(lines[#lines]) == '' do
    table.remove(lines)
  end
  if not lines[#lines] or not lines[#lines]:find('? for shortcuts', 1, true) then return false end
  for index = #lines - 1, math.max(1, #lines - 6), -1 do
    local line = vim.trim(lines[index])
    if line:find('›', 1, true) == 1 then return line == '› Ask Codex to do anything' end
  end
  return false
end

function M.paste(session)
  if #session.pending == 0 then return true end

  local text = table.concat(session.pending, '')
  -- A control character from an unsaved selection must remain text inside the paste.
  text = text:gsub('[%z\1-\8\11-\31\127]', function(char) return string.format('\\x%02x', char:byte()) end)
  if not M.send(session, '\27[200~' .. text .. '\27[201~') then return false end
  session.pending = {}
  return true
end

local function refresh_view(session, resize)
  local win = M.visible(session)
  if not win or not session.job then return end

  -- A full-screen TUI can leave a stale horizontal offset after the PTY size changes.
  if resize then pcall(vim.fn.jobresize, session.job, api.nvim_win_get_width(win), api.nvim_win_get_height(win)) end
  api.nvim_win_call(win, function()
    local view = vim.fn.winsaveview()
    if view.leftcol == 0 and view.skipcol == 0 then return end
    view.leftcol = 0
    view.skipcol = 0
    vim.fn.winrestview(view)
  end)
  vim.cmd.redraw({ bang = true })
end

local function watch_terminal(session, buf)
  local scheduled = false
  local function try_paste()
    if scheduled or #session.pending == 0 then return end
    scheduled = true
    vim.defer_fn(function()
      scheduled = false
      if session.buf == buf then M.paste(session) end
    end, 50)
  end

  api.nvim_create_autocmd('WinEnter', {
    buffer = buf,
    callback = function()
      local win = api.nvim_get_current_win()
      if session.job and api.nvim_win_get_buf(win) == buf then
        set_winbar(win)
        api.nvim_win_call(win, function() vim.cmd.startinsert() end)
      end
    end,
  })

  api.nvim_create_autocmd('TermLeave', {
    buffer = buf,
    callback = function() vim.wo.sidescrolloff = 0 end,
  })

  api.nvim_create_autocmd({ 'WinResized', 'VimResized' }, {
    buffer = buf,
    callback = function() refresh_view(session, true) end,
  })

  api.nvim_create_autocmd('TermRequest', {
    buffer = buf,
    callback = function(event)
      if session.buf ~= buf then return end
      local data = event.data.sequence:match('^\27%]7501;state=(.*)$')
      if not data then return end

      local state, app, detail = data:match('^(%a+):app=(%w+)(.*)$')
      if app == 'codex' then
        session.status = state
        session.prompt_kind = detail:match('^:kind=(%a+)$')
        try_paste()
      elseif data == 'clear' then
        session.status, session.prompt_kind = nil, nil
      end
    end,
  })
  api.nvim_buf_attach(buf, false, { on_lines = try_paste })
end

local function buffer_for(session)
  if not session.buf or not api.nvim_buf_is_valid(session.buf) then
    session.job, session.status, session.prompt_kind = nil, nil, nil
    session.buf = api.nvim_create_buf(false, true)
    vim.b[session.buf].codex_root = session.root
    vim.b[session.buf].codex_buffer_type = 'codex'
    vim.b[session.buf].codex_instance = session.instance_sequence
    vim.bo[session.buf].bufhidden = 'hide'
  end
  return session.buf
end

local function start(session, config, win, args)
  local argv = { config.codex_cmd }
  vim.list_extend(argv, config.codex_args)
  vim.list_extend(argv, args or {})
  local buf = session.buf
  local job = api.nvim_win_call(win, function()
    return vim.fn.jobstart(argv, {
      cwd = session.root,
      term = true,
      on_exit = function(id, code)
        if session.job ~= id then return end
        session.job, session.status, session.prompt_kind, session.pending = nil, nil, nil, {}
        vim.schedule(function()
          if session.buf ~= buf or not api.nvim_buf_is_valid(buf) then return end
          for _, target in ipairs(vim.fn.win_findbuf(buf)) do
            if api.nvim_win_is_valid(target) and api.nvim_win_get_buf(target) == buf then hide_window(session, target) end
          end
          if code ~= 0 then vim.notify(('Codex exited with code %d'):format(code), vim.log.levels.WARN, { title = 'Codex' }) end
        end)
      end,
    })
  end)
  if job <= 0 then error('Could not start the Codex executable', 0) end
  session.job = job
  vim.bo[buf].filetype = 'codex-terminal'
  watch_terminal(session, buf)
end

function M.show(session, config, focus, args)
  local tab = api.nvim_get_current_tabpage()
  local current = api.nvim_get_current_win()
  if not vim.b.codex_root and api.nvim_win_get_config(current).relative == '' then session.return_to[tab] = current end

  local win = M.visible(session)
  if session.buf and api.nvim_buf_is_valid(session.buf) and vim.bo[session.buf].buftype == 'terminal' and not session.job then
    local previous = session.buf
    session.buf = nil
    if win then api.nvim_win_set_buf(win, buffer_for(session)) end
    api.nvim_buf_delete(previous, { force = true })
  end

  local buf = buffer_for(session)
  if not win then
    local width = math.max(1, math.floor(vim.o.columns * config.split_width_percentage))
    win = api.nvim_open_win(buf, false, { split = 'right', win = -1, width = width })
    local options = vim.wo[win]
    options.number = false
    options.relativenumber = false
    options.signcolumn = 'no'
    options.foldcolumn = '0'
    options.statuscolumn = ''
    options.winfixwidth = true
  end
  if not session.job then start(session, config, win, args) end
  set_winbar(win)
  refresh_view(session, false)
  if focus then
    api.nvim_set_current_win(win)
    vim.cmd.startinsert()
  end
  vim.defer_fn(function()
    if session.buf == buf then M.paste(session) end
  end, 50)
end

return M
