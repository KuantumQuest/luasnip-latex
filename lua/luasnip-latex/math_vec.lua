local ls = require("luasnip")
local f = ls.function_node
local i = ls.insert_node

local M = {}

local vec_nodes = {
	f(function(_, parent)
		return ("\\vec{%s}"):format(parent.captures[1])
	end, {}),
	i(0),
}

M.math_wrA_no_backslash = {
	{ "([%a][%a])(%.,)", vec_nodes },
	{ "([%a][%a])(,%.)", vec_nodes },
	{ "([%a])(%.,)", vec_nodes },
	{ "([%a])(,%.)", vec_nodes },
}

M.decorator = {}

function M.retrieve(is_math)
	local utils = require("luasnip-latex.utils.utils")
	local pipe = utils.pipe
	local no_backslash = utils.no_backslash

	M.decorator = {
		wordTrig = true,
		trigEngine = "pattern",
		condition = pipe({ is_math, no_backslash }),
	}

	local s = ls.extend_decorator.apply(ls.snippet, M.decorator) --[[@as function]]

	return vim.tbl_map(function(x)
		local trig, node = unpack(x)
		return s({ trig = trig }, vim.deepcopy(node))
	end, M.math_wrA_no_backslash)
end

return M
