local M = {}

local api = vim.api
local floats = require('configs.terminal.floats')

function M.run_file()
  vim.cmd('w')
  local ft = vim.bo.filetype
  local file = vim.fn.expand('%:p')
  local is_win = require('utils').platform.is_win

  local function quote(value)
    if is_win then return "'" .. value:gsub("'", "''") .. "'" end
    return vim.fn.shellescape(value)
  end

  local function posix_quote(value) return "'" .. value:gsub("'", "'\\''") .. "'" end

  local function launch(command, cleanup)
    if is_win then
      local utf16 = vim.fn.iconv(command, 'utf-8', 'utf-16le')
      command = 'pwsh.exe -NoLogo -NoProfile -EncodedCommand ' .. vim.base64.encode(utf16)
    end
    floats.floaterm('RUN', command, nil, nil, cleanup)
  end

  local function launch_posix(command, cleanup)
    local script = vim.fn.tempname() .. '.sh'
    cleanup = cleanup or {}
    cleanup[#cleanup + 1] = { path = script }
    local trap_cleanup = [=[trap 'rm -f -- "$0"' 0]=]
    local written = vim.fn.writefile({ '#!/bin/sh', trap_cleanup, command }, script)
    if written ~= 0 then
      floats.cleanup_artifacts(cleanup)
      vim.notify('无法创建临时运行脚本: ' .. script, vim.log.levels.ERROR, { title = 'Terminal' })
      return
    end
    launch('sh ' .. vim.fn.shellescape(script), cleanup)
  end

  local function build_cmd(template)
    local escaped_file = quote(file)
    if template:find('{file}', 1, true) then return (template:gsub('{file}', function() return escaped_file end)) end
    return template .. ' ' .. escaped_file
  end

  local run_cmd = vim.tbl_extend('force', {
    javascript = 'node',
    typescript = 'ts-node',
    html = 'firefox',
    python = 'python3',
    go = 'go run',
    sh = 'bash',
    lua = 'lua',
  }, require('settings').file.run_cmd or {})

  if run_cmd[ft] then
    launch(build_cmd(run_cmd[ft]))
  elseif ft == 'markdown' then
    vim.cmd('MarkdownPreview')
  elseif ft == 'java' then
    -- package 项目应使用 JavaRunMain 或自定义 file.run_cmd.java。
    for _, line in ipairs(api.nvim_buf_get_lines(0, 0, -1, false)) do
      if line:match('^%s*package%s+[%w_%.]+%s*;') then
        vim.notify('带 package 的 Java 文件不支持 <leader>rf; 请使用 :JavaRunMain 或配置 file.run_cmd.java', vim.log.levels.WARN, { title = 'Terminal' })
        return
      end
    end
    local out_dir = vim.fn.tempname()
    if vim.fn.mkdir(out_dir, 'p') == 0 then
      vim.notify('无法创建 Java 临时编译目录: ' .. out_dir, vim.log.levels.ERROR, { title = 'Terminal' })
      return
    end
    local cleanup = { { path = out_dir, recursive = true } }
    if is_win then
      local command = string.format(
        'javac -d %s %s; $termRunStatus = if ($?) { $LASTEXITCODE } else { 1 }; '
          .. 'if ($termRunStatus -eq 0) { java -cp %s %s; $termRunStatus = if ($?) { $LASTEXITCODE } else { 1 } }; '
          .. 'Remove-Item -LiteralPath %s -Recurse -Force -ErrorAction SilentlyContinue; exit $termRunStatus',
        quote(out_dir),
        quote(file),
        quote(out_dir),
        quote(vim.fn.fnamemodify(file, ':t:r')),
        quote(out_dir)
      )
      launch(command, cleanup)
    else
      local command = string.format(
        'javac -d %s %s; term_run_status=$?; ' .. 'if [ "$term_run_status" -eq 0 ]; then java -cp %s %s; term_run_status=$?; fi; ' .. 'rm -rf -- %s; exit "$term_run_status"',
        posix_quote(out_dir),
        posix_quote(file),
        posix_quote(out_dir),
        posix_quote(vim.fn.fnamemodify(file, ':t:r')),
        posix_quote(out_dir)
      )
      launch_posix(command, cleanup)
    end
  elseif ft == 'c' or ft == 'rust' then
    local compiler = ft == 'c' and 'gcc' or 'rustc'
    local out = vim.fn.tempname() .. (is_win and '.exe' or '')
    local cleanup = { { path = out } }
    local command
    if is_win then
      command = string.format(
        '%s %s -o %s; $termRunStatus = if ($?) { $LASTEXITCODE } else { 1 }; '
          .. 'if ($termRunStatus -eq 0) { & %s; $termRunStatus = $LASTEXITCODE }; '
          .. 'Remove-Item -LiteralPath %s -Force -ErrorAction SilentlyContinue; exit $termRunStatus',
        compiler,
        quote(file),
        quote(out),
        quote(out),
        quote(out)
      )
      launch(command, cleanup)
    else
      command = string.format(
        '%s %s -o %s; term_run_status=$?; ' .. 'if [ "$term_run_status" -eq 0 ]; then %s; term_run_status=$?; fi; ' .. 'rm -f -- %s; exit "$term_run_status"',
        compiler,
        posix_quote(file),
        posix_quote(out),
        posix_quote(out),
        posix_quote(out)
      )
      launch_posix(command, cleanup)
    end
  else
    local label = ft ~= '' and ft or '当前 buffer'
    vim.notify(string.format('未配置 %s 的运行命令', label), vim.log.levels.WARN, { title = 'Terminal' })
  end
end

return M
