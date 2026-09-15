-- ==============================================================
-- 插件列表
-- ==============================================================
---@class PackUtils.Spec
---@field src string Git 仓库 URL
---@field version? string|vim.VersionRange 版本约束 (如 'v1.*') 或分支名 (如 'main')
---@field enabled? boolean|fun():boolean 是否启用 (默认 true)

-- 在 spec 中设置 enabled = false 可禁用插件:
--   不会下载(如果是新添加的), 跳过对应的 PackUtils.load, 已安装的会纳入清理
--   enabled 支持 boolean | function → boolean, 例如:
--     { src = 'https://...', enabled = false }
--     { src = 'https://...', enabled = function() return vim.fn.executable('some-tool') == 1 end }

---@type PackUtils.Spec[]
return {
  -- 公共依赖
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/MunifTanjim/nui.nvim' },

  -- theme
  { src = 'https://github.com/RRethy/base16-nvim' },

  -- lsp
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/mfussenegger/nvim-jdtls' },

  -- manson
  { src = 'https://github.com/mason-org/mason.nvim', enabled = require('settings').mason.enable },
  { src = 'https://github.com/williamboman/mason-lspconfig.nvim', enabled = require('settings').mason.enable },
  { src = 'https://github.com/jay-babu/mason-nvim-dap.nvim', enabled = require('settings').mason.enable },

  -- completion
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('v1.*') },
  { src = 'https://github.com/xzbdmw/colorful-menu.nvim' },
  { src = 'https://github.com/fang2hou/blink-copilot' },
  { src = 'https://github.com/L3MON4D3/LuaSnip', version = vim.version.range('v2.*') },
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
  { src = 'https://github.com/archie-judd/blink-cmp-words' },
  { src = 'https://github.com/Kaiser-Yang/blink-cmp-avante' },
  { src = 'https://github.com/windwp/nvim-autopairs' },

  -- debugging
  { src = 'https://github.com/mfussenegger/nvim-dap' },
  { src = 'https://github.com/rcarriga/nvim-dap-ui' },
  { src = 'https://github.com/theHamsta/nvim-dap-virtual-text' },
  { src = 'https://github.com/nvim-neotest/nvim-nio' },

  -- format
  { src = 'https://github.com/stevearc/conform.nvim' },

  -- treesitter
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-context' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects', version = 'main' },

  -- edit
  { src = 'https://github.com/windwp/nvim-ts-autotag' },
  { src = 'https://github.com/yetone/avante.nvim', enabled = false },
  { src = 'https://github.com/coder/claudecode.nvim' },
  { src = 'https://github.com/folke/ts-comments.nvim' },
  { src = 'https://github.com/kylechui/nvim-surround' },
  { src = 'https://github.com/AndrewRadev/switch.vim' },

  -- ui
  { src = 'https://github.com/brenoprata10/nvim-highlight-colors' },
  { src = 'https://github.com/lukas-reineke/indent-blankline.nvim' },
  { src = 'https://github.com/nvim-mini/mini.icons' },
  { src = 'https://github.com/folke/noice.nvim' },

  -- layout
  { src = 'https://github.com/Bekaboo/dropbar.nvim' },
  { src = 'https://github.com/rebelot/heirline.nvim' },
  { src = 'https://github.com/nvim-mini/mini.files' },
  { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
  { src = 'https://github.com/folke/snacks.nvim' },
  { src = 'https://github.com/akinsho/toggleterm.nvim' },
  { src = 'https://github.com/kevinhwang91/nvim-ufo' },
  { src = 'https://github.com/kevinhwang91/promise-async' },

  -- navigation
  { src = 'https://github.com/folke/flash.nvim' },

  -- git
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },

  -- workspace
  { src = 'https://github.com/coffebar/neovim-project' },
  { src = 'https://github.com/Shatur/neovim-session-manager' },

  -- docs
  { src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim' },
  { src = 'https://github.com/danymat/neogen' },
  { src = 'https://github.com/folke/todo-comments.nvim' },
  { src = 'https://github.com/yianwillis/vimcdoc' },

  -- tools
  { src = 'https://github.com/hakonharnes/img-clip.nvim' },
  { src = 'https://github.com/esmuellert/codediff.nvim' },
  { src = 'https://github.com/brianhuster/live-preview.nvim' },
  { src = 'https://github.com/uga-rosa/translate.nvim' },
  { src = 'https://github.com/linux-cultist/venv-selector.nvim' },
  { src = 'https://github.com/mistweaverco/kulala.nvim' },
  { src = 'https://github.com/tpope/vim-dadbod' },
  { src = 'https://github.com/kristijanhusak/vim-dadbod-ui' },
  { src = 'https://github.com/kristijanhusak/vim-dadbod-completion' },
}
