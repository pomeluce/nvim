vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    PackUtils.load({ name = 'live-preview.nvim' }, function()
      local Watcher = require('livepreview.server.fswatch').Watcher

      -- Upstream clears handles for deleted directories before the server stops.
      function Watcher:close()
        if self.watcher and not self.watcher:is_closing() then self.watcher:close() end
        for _, child in ipairs(self.children) do
          child:close()
        end
      end
    end)
  end,
})
