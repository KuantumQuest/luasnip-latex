local M = {}

local ls = require("luasnip")
local f = ls.function_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local i = ls.insert_node
local t = ls.text_node
local fmta = require("luasnip.extras.fmt").fmta

local get_visual = function(_, parent)
	local text = parent.snippet.env.LS_SELECT_DEDENT
	if #text > 0 then
		return sn(nil, { i(1, text) })
	else
		return sn(nil, { i(1) })
	end
end

local frac_parens_nodes = {
	d(1, function(_, parent)
		local match = parent.trigger
		local stripped = match:sub(1, #match - 2) --patrón útil capturado

		local idx = #stripped
		local depth = 0 -- Sirve para determinar que los paréntesis se hayan cerrado correctamente.
		while idx >= 0 do
			if stripped:sub(idx, idx) == ")" then
				depth = depth + 1
			elseif stripped:sub(idx, idx) == "(" then
				depth = depth - 1
			end
			if depth == 0 then
				break
			end
			idx = idx - 1 --recorriendo desde el final hasta el inicio de "stripped""
		end
		if depth ~= 0 then
			return sn(nil, { t(stripped .. "\\frac{"), i(1), t("}{"), i(2), t("}") })
		else
			return sn(nil, { t("\\frac{" .. stripped .. "}{"), i(1), t("}") })
		end
	end),
	i(0),
}

local frac_no_parens_triggers = {
	"(\\?[%w]+\\?%a*)ff", -- Ejemplo: \theta ó something
	"(\\?[%w]+\\?%a*^%w)ff", -- Ejemplo: \theta^e
	"(\\?[%w]+\\?%a*^{.*})ff", -- Ejemplo: \theta^{something..}
	"(\\?[%w]+\\?%a*_%w)ff", -- Ejemplo: \\theta_3
	"(\\?[%w]+\\?%a*_{.*})ff", -- Ejemplo: \\theta_{something}
}

local frac_no_parens_nodes = {
	f(function(_, snip)
		return string.format("\\frac{%s}", snip.captures[1])
	end, {}),
	t("{"),
	i(1),
	t("}"),
	i(0),
}

local subscript = {
	f(function(_, parent)
		return string.format("%s_{%s}", parent.captures[1], parent.captures[2])
	end),
}

function M.retrieve(is_math)
	local utils = require("luasnip-latex.utils.utils")
	local pipe = utils.pipe

	local s = ls.extend_decorator.apply(ls.snippet, {
		--trigEngine = "pattern",
		condition = pipe({ is_math }),
	}) --[[@as function]]
	local snippets = {
		s(
			{ trig = "ff", name = "fraction", wordTrig = true },
			fmta("\\frac{<>}{<>} <>", { d(1, get_visual), i(2), i(0) })
		),
		s(
			{ trig = ".*%)ff", name = "() fraction", wordTrig = false, regTrig = true, priority = 10 },
			vim.deepcopy(frac_parens_nodes)
		),
		s({ trig = "(%a)(%d)", name = "auto subscript, one number", regTrig = true }, vim.deepcopy(subscript)),
		s({ trig = "(%a)_(%d%d)", name = "auto subscript, two number", regTrig = true }, vim.deepcopy(subscript)),
	}
	for _, pattern in ipairs(frac_no_parens_triggers) do
		snippets[#snippets + 1] = s(
			{ trig = pattern, name = "[somethin]fraction", worTrig = false, regTrig = true, priority = 10 },
			vim.deepcopy(frac_no_parens_nodes)
		)
	end
	return snippets
end

return M
