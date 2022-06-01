local d = require("stl.data")
local h = require("stl.highlight")
local gps_ok, gps = pcall(require, "nvim-gps")

local M = {}

M.spacer = "%="
M.space = " "

function M.escape(str)
	return str:gsub("%%", "%%%%")
end

function M.non_empty(tbl)
	local out = {}

	for i = 1, #tbl, 1 do
		local value = tbl[i]

		if (type(value) == "string" and value ~= "") or (type(value) == "table" and (#value > 0 or value.__hl)) then
			table.insert(out, value)
		end
	end

	return out
end

function M.hl_wrap(tbl)
	return { h.hl(tbl), tbl, h.hl() }
end

function M.join(tbl)
	local non_empty = M.non_empty(tbl)

	if #non_empty == 0 then
		return
	end

	local out = {}
	for index, value in ipairs(non_empty) do
		table.insert(out, value)
		if index ~= #non_empty then
			table.insert(out, tbl.sep or " ")
		end
	end

	return out
end

function M.generic_blocks(tbl, chars)
	local side = tbl.side

	if not side then
		side = "center"
	end

	local out = {}

	local non_empty_blocks = M.non_empty(tbl)

	if #non_empty_blocks == 0 then
		return
	end

	for index, block in ipairs(non_empty_blocks) do
		local non_empty_children = M.non_empty(block)

		if #non_empty_children > 0 then
			local prev = non_empty_blocks[index - 1] and non_empty_blocks[index - 1].bg
			local next = non_empty_blocks[index + 1] and non_empty_blocks[index + 1].bg

			if side == "left" then
				table.insert(out, M.hl_wrap { bg = block.bg, fg = block.fg, " ", non_empty_children, chars[2] })
				table.insert(out, M.hl_wrap { fg = block.bg, bg = next, chars[3] })
			elseif side == "center" then
				table.insert(out, M.hl_wrap { bg = block.bg, fg = block.fg, (prev and " " or chars[2]), non_empty_children, (next and " " or chars[2]) })
			elseif side == "right" then
				table.insert(out, M.hl_wrap { fg = block.bg, bg = prev, chars[1] })
				table.insert(out, M.hl_wrap { bg = block.bg, fg = block.fg, chars[2], non_empty_children, " " })
			end
		end
	end

	if side == "center" then
		table.insert(out, 1, M.hl_wrap { fg = non_empty_blocks[1].bg, chars[1] })
		table.insert(out, M.hl_wrap { fg = non_empty_blocks[#non_empty_blocks].bg, chars[3] })
	end

	return out
end

function M.round_blocks(tbl)
	return M.generic_blocks(tbl, { "", "", "" })
end

function M.slant_blocks(tbl)
	return M.generic_blocks(tbl, { "", " ", "" })
end

function M.triangle_blocks(tbl)
	return M.generic_blocks(tbl, { "", " ", "" })
end

function M.vi_mode(colors)
	local mode = vim.fn.mode(1)
	return M.hl_wrap {
		bg = colors and colors[mode:sub(1, 1)],
		invert = true,
		" " .. d.vi_mode_names[mode] .. " "
	}
end

function M.file_icon(buf)
	local filename = vim.api.nvim_buf_get_name(buf or 0)
	local extension = vim.fn.fnamemodify(filename, ":e")

	local icon, icon_color = require('nvim-web-devicons').get_icon_color(
		filename,
		extension
	)

	if icon then
		return M.hl_wrap { fg = icon_color, icon }
	end
end

function M.file_name(buf)
	local filename = vim.api.nvim_buf_get_name(buf or 0)

	if filename == "" then
		return
	end

	return M.escape(vim.fn.fnamemodify(filename, ":t"))
end

function M.file_size(buf)
	local suffix = { 'b', 'k', 'M', 'G', 'T', 'P', 'E' }
	local index = 1

	local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(buf or 0))

	if fsize < 0 then
		return
	end

	while fsize > 1024 and index < 7 do
		fsize = fsize / 1024
		index = index + 1
	end

	return string.format(index == 1 and '%g%s' or '%.2f%s', fsize, suffix[index])
end

function M.file_modified(buf)
	if vim.api.nvim_buf_get_option(buf or 0, "modified") then
		return ""
	end
end

function M.file_readonly(buf)
	if vim.api.nvim_buf_get_option(buf or 0, "readonly") then
		return ""
	end
end

function M.diagnostics(kind, buf)
	local count = #vim.diagnostic.get(buf or 0, { severity = d.diagnostics[kind].severity })

	if count == 0 then
		return
	end

	local sign = d.diagnostics[kind].sign
	return sign .. count
end

function M.context()
	if gps_ok and gps.is_available() then
		return gps.get_location()
	end
end

function M.git_status(kind, buf)
	local ok, status = pcall(vim.api.nvim_buf_get_var, buf or 0, "gitsigns_status_dict")
	if ok and status[kind] and status[kind] ~= 0 and status[kind] ~= "" then
		return d.git_icons[kind] .. " " .. status[kind]
	end
end

return M
