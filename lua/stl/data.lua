local M = {}

M.vi_mode_names = {
	n = "N",
	no = "N?",
	nov = "N?",
	noV = "N?",
	["no\22"] = "N?",
	niI = "Ni",
	niR = "Nr",
	niV = "Nv",
	nt = "Nt",
	v = "V",
	vs = "Vs",
	V = "V_",
	Vs = "Vs",
	["\22"] = "^V",
	["\22s"] = "^V",
	s = "S",
	S = "S_",
	["\19"] = "^S",
	i = "I",
	ic = "Ic",
	ix = "Ix",
	R = "R",
	Rc = "Rc",
	Rx = "Rx",
	Rv = "Rv",
	Rvc = "Rv",
	Rvx = "Rv",
	c = "C",
	cv = "Ex",
	r = "...",
	rm = "M",
	["r?"] = "?",
	["!"] = "!",
	t = "T",
}

local gs = vim.fn.sign_getdefined

local error = gs("DiagnosticSignError")
local warn = gs("DiagnosticSignWarn")
local info = gs("DiagnosticSignInfo")
local hint = gs("DiagnosticSignHint")

M.diagnostics = {
	error = {
		sign = error and error[1] and error[1].text,
		severity = vim.diagnostic.severity.ERROR
	},
	warn = {
		sign = warn and warn[1] and warn[1].text,
		severity = vim.diagnostic.severity.WARN
	},
	info = {
		sign = info and info[1] and info[1].text,
		severity = vim.diagnostic.severity.INFO
	},
	hint = {
		sign = hint and hint[1] and hint[1].text,
		severity = vim.diagnostic.severity.HINT
	},
}

M.git_icons = {
	added = "",
	removed = "",
	changed = "",
	head = "",
}

return M
