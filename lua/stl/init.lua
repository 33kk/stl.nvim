local c = require("stl.components")
local u = require("stl.utils")

local M = {}
-- TODO: per filetype/buftype/bufname statuslines

function M.create(fn)
	return function()
		return u.preprocess(c.hl_wrap(fn()))
	end
end

return M
