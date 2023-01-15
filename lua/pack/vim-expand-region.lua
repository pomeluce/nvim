local G = require('G')
local M = {}

function M.config()
	G.map({
		{ 'v', 'v', '<Plug>(expand_region_expand)', G.opt_sil },
    { 'v', 'V', '<Plug>(expand_region_shrink)', G.opt_sil },
	})
end

function M.setup()
	-- do nothing
end

return M
