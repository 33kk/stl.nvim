local h = require("stl.highlight")

local M = {}

function M.to_hex(number)
	return string.format("#%x", number)
end

function M.get_hl_by_name(name)
	local ok, hl = pcall(vim.api.nvim_get_hl_by_name, name, true);

	if not ok then
		return
	end

	return { fg = M.to_hex(hl.foreground), bg = M.to_hex(hl.background), sp = M.to_hex(hl.special), invert = hl.reverse }
end

function M.is_win_active(winid)
	if not winid then
		winid = vim.api.nvim_get_current_win()
	end
	local curwin = tonumber(vim.g.actual_curwin)
	return winid == curwin
end

function M.get_tabs()
	local out = {}

	local active_nr = vim.fn.tabpagenr()
	for _, value in ipairs(vim.fn.gettabinfo()) do
		local wininfos = M.getwininfos(value.windows)

		table.insert(out, {
			active = value.tabnr == active_nr,
			wininfos = wininfos,
			biggest = M.find_biggest_window(wininfos)
		})
	end

	return out
end

function M.preprocess(stl)
	return table.concat(
		h.render_highlights(
			M.flatten(
				stl
			)
		)
	)
end

function M.flatten(tbl)
	local out = {}

	for i = 1, #tbl, 1 do
		local value = tbl[i]

		if type(value) == "table" then
			if value.__hl then
				table.insert(out, value)
			else
				local flattened = M.flatten(value)
				for j = 1, #flattened, 1 do
					table.insert(out, flattened[j])
				end
			end
		elseif value and value ~= "" then
			table.insert(out, value)
		end
	end

	return out
end

function M.getwininfos(winids)
	local out = {}

	for _, winid in ipairs(winids) do
		table.insert(out, vim.fn.getwininfo(winid)[1])
	end

	return out
end

function M.calculate_window_weight(wininfo)
	return wininfo.height * ( wininfo.width / 3 )
end

-- TODO: filetype/buftype priority
function M.find_biggest_window(wininfos)
	local out = wininfos[1]
	local max = 0

	for _, wininfo in ipairs(wininfos) do
		local cur = M.calculate_window_weight(wininfo)

		if cur > max then
			max = cur
			out = wininfo
		end
	end

	return out
end

return M
