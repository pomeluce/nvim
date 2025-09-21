local M = {}

function M.config()
  -- do nothing
end

function M.setup()
  return function()
    local codecompanion = require('codecompanion')
    local adapters = require('codecompanion.adapters')

    local opts = {
      adapters = {
        http = {
          deepseek = function()
            return adapters.extend('deepseek', {
              name = 'deepseek',
              env = {
                api_key = function()
                  return os.getenv('DEEPSEEK_API_KEY')
                end,
              },
              schema = { model = { default = 'deepseek-coder' } },
            })
          end,
          siliconflow_r1 = function()
            return adapters.extend('deepseek', {
              name = 'siliconflow_r1',
              url = 'https://api.siliconflow.cn/v1/chat/completions',
              env = {
                api_key = function()
                  return os.getenv('DEEPSEEK_API_KEY_S')
                end,
              },
              schema = {
                model = {
                  default = 'deepseek-ai/DeepSeek-R1',
                  choices = { ['deepseek-ai/DeepSeek-R1'] = { opts = { can_reason = true } }, 'deepseek-ai/DeepSeek-V3' },
                },
              },
            })
          end,
          siliconflow_v3 = function()
            return adapters.extend('deepseek', {
              name = 'siliconflow_v3',
              url = 'https://api.siliconflow.cn/v1/chat/completions',
              env = {
                api_key = function()
                  return os.getenv('DEEPSEEK_API_KEY_S')
                end,
              },
              schema = {
                model = {
                  default = 'deepseek-ai/DeepSeek-V3',
                  choices = { 'deepseek-ai/DeepSeek-V3', ['deepseek-ai/DeepSeek-R1'] = { opts = { can_reason = true } } },
                },
              },
            })
          end,
          aliyun_deepseek = function()
            return adapters.extend('deepseek', {
              name = 'aliyun_deepseek',
              url = 'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions',
              env = {
                api_key = function()
                  return os.getenv('DEEPSEEK_API_ALIYUN')
                end,
              },
              schema = {
                model = {
                  default = 'deepseek-r1',
                  choices = {
                    ['deepseek-r1'] = { opts = { can_reason = true } },
                  },
                },
              },
            })
          end,
          -- copilot pro 可用
          -- copilot_claude = function()
          --   return adapters.extend('copilot', {
          --     name = 'copilot_claude',
          --     schema = {
          --       model = {
          --         default = 'claude-3.7-sonnet',
          --       },
          --     },
          --   })
          -- end,
        },
      },
      strategies = {
        chat = { adapter = 'siliconflow_r1' },
        inline = { adapter = 'siliconflow_v3' },
      },
      opts = { language = 'Chinese' },
      prompt_library = {
        ['DeepSeek Explain'] = require('user.configs.ai.prompts.deepseek-explain'),
      },
    }

    codecompanion.setup(opts)
  end
end

return M
