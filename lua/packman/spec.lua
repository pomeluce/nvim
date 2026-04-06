local M = {}

--- 将短格式 'owner/repo' 转换为完整 GitHub URL
--- 已是完整 URL 的直接返回
---@param src string
---@return string
function M.parse_src(src)
  if src:match('^https?://') then return src end
  return 'https://github.com/' .. src .. '.git'
end

--- 从 src 推断插件名(去掉 .git 后缀, 取最后一段)
---@param src string
---@return string
function M.infer_name(src)
  local url = M.parse_src(src)
  url = url:gsub('%.git$', '')
  return url:match('/([^/]+)$')
end

--- 从插件名推断 Lua 模块名(去掉 .nvim/.lua/.vim 后缀)
--- 对于 name='noice.nvim' → 'noice', name='blink.cmp' → 'blink.cmp'
---@param name string
---@return string
function M.infer_main(name) return (name:gsub('%.nvim$', ''):gsub('%.lua$', ''):gsub('%.vim$', '')) end

--- 解析单个 spec
---@param spec table|string
---@return table parsed
function M.parse(spec)
  if type(spec) == 'string' then spec = { spec } end

  -- import 字段
  if spec.import then return { import = spec.import } end

  -- src: 第一个元素或 'src' 字段
  local src = spec[1] or spec.src
  if not src or type(src) ~= 'string' then error('packman: plugin spec must have a src') end

  local parsed = {
    src = M.parse_src(src),
    name = spec.name or M.infer_name(src),
    enabled = spec.enabled ~= false,
  }

  -- version: 支持 semver range 字符串、vim.version.range() 对象、或 git branch 名(如 'main')
  if spec.version then
    if type(spec.version) == 'string' then
      -- 尝试解析为 semver range，失败则作为原始字符串（如 git branch 名）
      local ok, v = pcall(vim.version.range, spec.version)
      parsed.version = ok and v or spec.version
    else
      parsed.version = spec.version
    end
  end

  -- opts 和 config
  parsed.opts = spec.opts
  parsed.config = spec.config

  -- main: 覆盖推断的模块名
  if spec.main then parsed.main = spec.main end

  -- 延迟加载条件
  parsed.event = spec.event
  parsed.keys = spec.keys
  parsed.cmd = spec.cmd
  parsed.ft = spec.ft

  -- 依赖
  parsed.dependencies = spec.dependencies

  return parsed
end

--- 判断是否为延迟加载
---@param spec table
---@return boolean
function M.is_lazy(spec) return not not (spec.event or spec.keys or spec.cmd or spec.ft) end

return M
