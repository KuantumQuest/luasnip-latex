-- Solo math
--- Snippets fáciles.

local M = {}

local ls = require("luasnip")
local utils = require("luasnip-latex.utils.utils")
local pipe = utils.pipe

function M.retrieve(is_math)
	local s = ls.extend_decorator.apply(ls.snippet, {
		wordTrig = false,
		condition = pipe({ is_math }), -- Esta variable es una función compuesta!
		show_condition = is_math,
	})
	local fmta = require("luasnip.extras.fmt").fmta
	local i = ls.insert_node
	local d = ls.dynamic_node
	local sn = ls.snippet_node
	local rep = require("luasnip.extras").rep

	local get_save_text = function(_, parent)
		local t = parent.snippet.env.LS_SELECT_DEDENT
		if #t > 0 then
			return sn(nil, { i(1, t) })
		else
			return sn(nil, { i(1) })
		end
	end

	return {
		s(
			{
				trig = "sum",
				name = "sum",
			},
			fmta("\\sum_{<>=<>}^{<>} <>", {
				i(1, "n"),
				i(2, "1"),
				i(3, "\\infty"),
				d(4, get_save_text, {}),
			})
		),
		s(
			{
				trig = "tal",
				name = "taylor",
			},
			fmta("\\sum_{<>=<>}^{<>} \\frac{<>^{(<>)}(<>)}{<>!} (x-<>)^{<>} <>", {
				i(1, "n"),
				i(2, "0"),
				i(3, "\\infty"),
				i(4, "f"),
				rep(1),
				i(5, "x_0"),
				rep(1),
				rep(5),
				rep(1),
				i(0),
			}),
			{
				repeat_duplicates = true,
			}
		),
		s(
			{
				trig = "prd",
				name = "product",
			},
			fmta("\\prod_{<>=<>}^{<>} <>", {
				i(1, "n"),
				i(2, "1"),
				i(3, "\\infty"),
				d(4, get_save_text, {}),
			})
		),
		s(
			{
				trig = "lm",
				name = "limit",
			},
			fmta("\\lim_{<> \\to <>} <>", {
				i(1, "x"),
				i(2, "\\infty"),
				d(3, get_save_text, {}),
			})
		),
		s(
			{
				trig = "par",
				name = "Derivada parcial",
				desc = "Derivada parcial en modo función (df/dx)",
			},
			fmta([[\frac{\partial <>}{\partial <>} <>]], {
				i(1, "f"),
				i(2, "x"),
				i(3),
			})
		),
		s(
			{
				trig = "ddx",
				name = "d/dx",
			},
			fmta([[\frac{\mathrm{d<>}{\mathrm{d<>}}} <>]], {
				i(1, "f"),
				i(2, "x"),
				i(0),
			})
		),
		-- parse_snippet({ trig = "pmat", name = "pmat" }, "\\begin{pmatrix} $1 \\end{pmatrix} $0"),
		s(
			{
				trig = "lrp",
				name = "left( right)",
			},
			fmta([[\left( <> \right) <>]], {
				d(1, get_save_text, {}),
				i(0),
			})
		),
		s(
			{
				trig = "lri",
				name = "left| right|",
			},
			fmta([[\left| <> \right| <>]], {
				d(1, get_save_text, {}),
				i(0),
			})
		),
		s(
			{
				trig = "lrl",
				name = "left{ right}",
			},
			fmta([[\left\{ <> \right\} <>]], {
				d(1, get_save_text, {}),
				i(0),
			})
		),
		s(
			{
				trig = "lrc",
				name = "left[ right]",
			},
			fmta([[\left[ <> \right] <>]], {
				d(1, get_save_text, {}),
				i(0),
			})
		),
		s(
			{
				trig = "lra",
				name = "left< right>",
			},
			fmta([[\left<< <> \right>> <>]], {
				d(1, get_save_text, {}),
				i(0),
			})
		),
		s(
			{
				trig = "seq",
				name = "Sequence (series)",
			},
			fmta([[\left({<>}_{<>}\right)_{<>=<>}^{<>} <>]], {
				i(1, "a"),
				i(2, "n"),
				rep(2),
				i(3, "m"),
				i(4, "\\infty"),
				i(0),
			}, {
				repeat_duplicates = true,
			})
		),
	}
end
return M
