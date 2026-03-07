vim.pack.add({
  { src = 'https://github.com/yetone/avante.nvim', data = { build = 'make' } },
})

vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('SetupAvante', { clear = true }),
  callback = function()
    require('utils').pack_build('avante.nvim', { 'make' })
    require('avante').setup({
      provider = 'coder:qwen3.5-plus',
      input = { provider = 'snacks', provider_opts = { title = 'Avante Input', icon = '󱂛 ', placeholder = 'Enter your API key...' } },
      providers = {
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
        ['coder:qwen3.5'] = {
          __inherited_from = 'openai',
          api_key_name = 'SILICONFLOW_API_KEY',
          endpoint = 'https://api.siliconflow.cn/v1/chat/completions',
          model = 'Qwen/Qwen3.5-122B-A10B',
        },
        ['coder:deepseek-v3.2-pro'] = {
          __inherited_from = 'openai',
          api_key_name = 'SILICONFLOW_API_KEY',
          endpoint = 'https://api.siliconflow.cn/v1/chat/completions',
          model = 'Pro/deepseek-ai/DeepSeek-V3.2',
        },
        ['coder:deepseek'] = {
          __inherited_from = 'openai',
          api_key_name = 'DEEPSEEK_API_KEY',
          endpoint = 'https://api.deepseek.com',
          model = 'deepseek-coder',
        },
      },
    })
  end,
})
