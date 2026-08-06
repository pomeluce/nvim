local M = {}

---@class LspServerEntry
---@field filetypes string|string[]
---@field names string[]

---@type LspServerEntry[]
M.servers = {
  { filetypes = 'python', names = { 'ty' } },
  { filetypes = { 'bash', 'sh', 'zsh' }, names = { 'bashls' } },
  { filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' }, names = { 'clangd' } },
  { filetypes = 'cmake', names = { 'cmake' } },
  { filetypes = { 'css', 'scss', 'less' }, names = { 'cssls' } },
  { filetypes = { 'dockerfile', 'yaml.docker-compose' }, names = { 'docker_language_server' } },
  {
    filetypes = {
      'astro',
      'css',
      'eruby',
      'html',
      'htmldjango',
      'javascriptreact',
      'less',
      'sass',
      'scss',
      'svelte',
      'typescriptreact',
      'vue',
    },
    names = { 'emmet_language_server' },
  },
  { filetypes = 'html', names = { 'html' } },
  { filetypes = { 'json', 'jsonc' }, names = { 'jsonls' } },
  { filetypes = 'kotlin', names = { 'kotlin_language_server' } },
  { filetypes = 'lua', names = { 'lua_ls' } },
  { filetypes = { 'markdown', 'markdown.mdx' }, names = { 'marksman' } },
  { filetypes = 'nix', names = { 'nixd' } },
  { filetypes = 'rust', names = { 'rust_analyzer' } },
  {
    filetypes = {
      'astro',
      'clojure',
      'htmldjango',
      'elixir',
      'eruby',
      'haml',
      'html',
      'htmlangular',
      'heex',
      'liquid',
      'markdown',
      'php',
      'twig',
      'css',
      'less',
      'sass',
      'scss',
      'stylus',
      'javascript',
      'javascriptreact',
      'rescript',
      'typescript',
      'typescriptreact',
      'vue',
      'svelte',
    },
    names = { 'tailwindcss' },
  },
  { filetypes = 'toml', names = { 'taplo' } },
  {
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
    names = { 'ts_ls', 'vue_ls' },
  },
  { filetypes = 'xml', names = { 'lemminx' } },
}

function M.mason_servers()
  local result, seen = {}, {}
  local function add(name)
    if seen[name] then return end
    seen[name] = true
    result[#result + 1] = name
  end

  for _, item in ipairs(M.servers) do
    for _, name in ipairs(item.names) do
      add(name)
    end
  end
  table.sort(result)
  return result
end

return M
