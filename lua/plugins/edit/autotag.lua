---@type packman.SpecItem[]
return {
  {
    'windwp/nvim-ts-autotag',
    ft = { 'html', 'javascriptreact', 'typescriptreact', 'vue' },
    opts = {
      opts = { enable_rename = true, enable_close = true, enable_close_on_slash = true },
    },
  },
}
