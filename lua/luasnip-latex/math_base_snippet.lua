local M = {}

local ls = require("luasnip")
local utils = require("luasnip-latex.utils.utils")
local pipe = utils.pipe

function M.retrieve(is_math)
	local s = ls.extend_decorator.apply(ls.snippet, {
		condition = pipe({ is_math }), -- Esta variable es una función compuesta!
		-- show_condition = is_math,
	})
	local fmta = require("luasnip.extras.fmt").fmta
	local t = ls.text_node
	local i = ls.insert_node
	local f = ls.function_node
	local rep = require("luasnip.extras").rep

	return {
		s(
			{
				trig = "seq",
				name = "Sequence (series)",
			},
			fmta([[\left\{{<>}_{<>}\right\}_{<>=<>}^{<>}<>]], {
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
		-- Diff: Newton notation
		s({
			trig = "(\\?%a+)d",
			wordTrig = false,
			regTrig = true,
			name = "dot",
			priority = 10,
		}, {
			f(function(_, parent)
				return ("\\dot{%s}"):format(parent.captures[1])
			end),
			i(0),
		}),
		s({
			trig = "(\\?%a+)dd",
			wordTrig = false,
			regTrig = true,
			name = "ddot",
			priority = 20,
		}, {
			f(function(_, parent)
				return ("\\ddot{%s}"):format(parent.captures[1])
			end),
			i(0),
		}),
		s({
			trig = "(\\?%a+)ddd",
			wordTrig = false,
			regTrig = true,
			name = "dddot",
			priority = 30,
		}, {
			f(function(_, parent)
				return ("\\dddot{%s}"):format(parent.captures[1])
			end),
			i(0),
		}),
		s({
			trig = "(\\?%a+)dddd",
			wordTrig = false,
			regTrig = true,
			name = "ddddot",
			priority = 40,
		}, {
			f(function(_, parent)
				return ("\\ddddot{%s}"):format(parent.captures[1])
			end),
			i(0),
		}),

		--Espacio
		s({ trig = "+", name = "quad", wordTrig = false }, { t("\\quad") }),
		s({ trig = "++", name = "quad", wordTrig = false, priority = 10 }, { t("\\qquad") }),

    -- Function
		s(
			{ trig = "fun", name = "function map", wordTrig = false },
			fmta([[<>\colon <>\mathbb{R} \to <>\mathbb{R}]], { i(1, "g"), i(2), i(3) })
		),
	}
end

return M
