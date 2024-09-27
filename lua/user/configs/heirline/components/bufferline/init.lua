local utils = require('user.configs.heirline.utils')

local close = require('user.configs.heirline.components.bufferline.close')
local filename = require('user.configs.heirline.components.bufferline.filename')
local truncation = require('user.configs.heirline.components.bufferline.truncation')

local offset = require('user.configs.heirline.components.bufferline.offset')
local pages = require('user.configs.heirline.components.bufferline.pages')
local buffers = {
  require('heirline.utils').make_buflist(
    {
      filename,
      close,
      utils.space(2),
    },
    -- 左截断
    truncation.left,
    -- 右截断
    truncation.right
  ),
  utils.align,
}

return {
  hl = { bg = 'NONE' },
  offset,
  buffers,
  pages,
}
