local hl_groups = {}

local M = {}

function M.hl(hl_tbl)
	if not hl_tbl then
		return { __hl = { pop = true } }
	else
		return { __hl = { fg = hl_tbl.fg, bg = hl_tbl.bg, sp = hl_tbl.sp, invert = hl_tbl.invert } }
	end
end

local function render_hl(hl_tbl)
	if not hl_tbl then
		return
	end

	local hl_tbl_name = "StatusLine"
		.. (hl_tbl.fg and hl_tbl.fg:gsub("#", "") or "_")
		.. (hl_tbl.bg and hl_tbl.bg:gsub("#", "") or "_")
		.. (hl_tbl.sp and hl_tbl.sp:gsub("#", "") or "_")

	if not hl_groups[hl_tbl_name] then
		hl_groups[hl_tbl_name] = true

		vim.api.nvim_set_hl(0, hl_tbl_name, { fg = hl_tbl.fg, bg = hl_tbl.bg, sp = hl_tbl.sp })
	end

	return "%#"..hl_tbl_name.."#"
end

function M.render_highlights(tbl)
	local out = {}

	local hls = {}
	for _, value in ipairs(tbl) do
		if value.__hl then
			if value.__hl.pop then
				table.remove(hls)
			elseif value.__hl.invert then
				table.insert(hls, { bg = value.__hl.bg or hls[#hls].fg, fg = value.__hl.fg or hls[#hls].bg, sp = value.__hl.sp or hls[#hls].sp })
			else
				table.insert(hls, vim.tbl_extend("force", hls[#hls] or {}, value.__hl))
			end
			table.insert(out, render_hl(hls[#hls] or {}))
		else
			table.insert(out, value)
		end
	end

	return out
end

return M
