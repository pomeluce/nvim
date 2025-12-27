function _G.intelli_flod()
  local spacetext = ('        '):sub(0, vim.opt.shiftwidth:get())
  local line = vim.fn.getline(vim.v.foldstart):gsub('\t', spacetext)
  local folded = vim.v.foldend - vim.v.foldstart + 1
  local findresult = line:find('%S')
  if not findresult then
    return '+ folded ' .. folded .. ' lines '
  end
  local empty = findresult - 1
  local funcs = {
    [0] = function(_)
      return '' .. line
    end,
    [1] = function(_)
      return '+' .. line:sub(2)
    end,
    [2] = function(_)
      return '+ ' .. line:sub(3)
    end,
    [-1] = function(c)
      local result = ' ' .. line:sub(c + 1)
      local foldednumlen = #tostring(folded)
      for _ = 1, c - 2 - foldednumlen do
        result = '-' .. result
      end
      return '+' .. folded .. result
    end,
  }
  return funcs[empty <= 2 and empty or -1](empty) .. ' folded ' .. folded .. ' lines '
end

vim.g.base46_cache = vim.fn.stdpath('data') .. '/base46_cache/'

-- 声明 leader 键
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- 设置 python3 对应的目录, 你可以手动 export PYTHON=$(which python3) 到你的终端配置中
vim.g.python3_host_prog = os.getenv('PYTHON')

-- 禁用语言的默认提供者
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- 全局变量用于保存 root_dir -> dialect 的映射
vim.g.sql_dialect_override = {}
