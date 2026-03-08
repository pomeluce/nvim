vim.pack.add({
  { src = 'https://github.com/yetone/avante.nvim', data = { build = 'make' } },
})

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('SetupAvante', { clear = true }),
  callback = function()
    require('utils').pack_build('avante.nvim', { 'make' })
    local models = require('utils').read_json(os.getenv('HOME') .. '/.config/avante.nvim/models.json')
    require('avante').setup({
      provider = 'coder:qwen3.5-plus',
      input = { provider = 'snacks', provider_opts = { title = 'Avante Input', icon = '󱂛 ', placeholder = 'Enter your API key...' } },
      providers = vim.tbl_deep_extend('force', {
        ['coder:qwen3'] = {
          __inherited_from = 'openai',
          endpoint = 'https://openrouter.ai/api/v1',
          api_key_name = 'OPENROUTER_API_KEY',
          model = 'qwen/qwen3-coder:free',
        },
        ['coder:qwen3.5-plus'] = {
          __inherited_from = 'openai',
          api_key_name = 'ALIYUN_API_KEY',
          endpoint = 'https://dashscope.aliyuncs.com/compatible-mode/v1',
          model = 'qwen3.5-plus',
        },
        ['coder:qwen3.5-flash'] = {
          __inherited_from = 'openai',
          api_key_name = 'ALIYUN_API_KEY',
          endpoint = 'https://dashscope.aliyuncs.com/compatible-mode/v1',
          model = 'qwen3.5-flash',
        },
        ['coder:deepseek'] = {
          __inherited_from = 'openai',
          api_key_name = 'DEEPSEEK_API_KEY',
          endpoint = 'https://api.deepseek.com',
          model = 'deepseek-coder',
        },
      }, models or {}),
    })
  end,
})
