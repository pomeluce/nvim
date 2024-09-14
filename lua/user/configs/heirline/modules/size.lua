local colors = require('user.configs.heirline.colors')
local utils = require('user.configs.heirline.utils')

return {
  {
    provider = utils.separators.left,
    hl = { fg = colors.pink },
  },
  {
    provider = ' ',
    hl = { fg = colors.black2, bg = colors.pink },
  },
  {
    provider = function()
      -- stackoverflow, compute human readable file size
      local suffix = { 'b', 'k', 'M', 'G', 'T', 'P', 'E' }
      local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
      fsize = (fsize < 0 and 0) or fsize
      if fsize < 1024 then
        return ' ' .. fsize .. suffix[1]
      end
      local i = math.floor((math.log(fsize) / math.log(1024)))
      return string.format(' %.2g%s', fsize / math.pow(1024, i), suffix[i + 1])
    end,
  },
  utils.space(1),
}
