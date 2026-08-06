local enable = require('utils').lsp.enable_server
local registry = require('configs.lsp-servers')

vim.lsp.enable('copilot')

vim.filetype.add({
  filename = { ['docker-compose.yml'] = 'yaml.docker-compose', ['docker-compose.yaml'] = 'yaml.docker-compose' },
  pattern = { ['docker%-compose.*%.ya?ml'] = 'yaml.docker-compose' },
})

for _, server in ipairs(registry.servers) do
  enable(server.filetypes, server.names)
end
