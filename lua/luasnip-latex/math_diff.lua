local M = {}

local ls = require("luasnip")
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

function M.retrieve(is_math)
	local utils = require("luasnip-latex.utils.utils")
	local pipe, no_backslash = utils.pipe, utils.no_backslash

	local s = ls.extend_decorator.apply(ls.snippet, {
		condition = pipe({ is_math }),
	})
  return {
		-- Limites
		s({ trig = "ooo", name = "Symbol infinite" }, { t("\\infty") }),
		s({ trig = "lim", name = "limit" }, fmta("\\lim_{<> \\to <>}<>", { i(1, "x"), i(2, "\\infty"), d(3, get_visual) })),

    -- Derivadas
		s(
			{
				trig = "ddx",
				name = "d/dx",
			},
			fmta([[\frac{d<>}{d<>}<>]], {
				i(1),
				i(2, "x"),
        d(3, get_visual)
			})
		),
		s(
			{
				trig = "par1",
				name = "Derivada parcial",
				desc = "Derivada parcial en modo función (df/dx)",
			},
			fmta([[\frac{\partial <>}{\partial <>}<>]], {
				i(1, "f"),
				i(2, "x"),
        d(3, get_visual)
			})
		),
		s(
			{
				trig = "par2",
				name = "Derivada parcial doble",
				desc = "Derivada parcial doble de una variable",
			},
			fmta([[\frac{\partial^2 <>}{\partial <> ^2}<>]], {
				i(1),
				i(2, "x"),
        d(3, get_visual)
			})
		),
		s(
			{
				trig = "parxy",
				name = "Derivada parcial doble",
				desc = "Derivada parcial doble mixta",
			},
			fmta([[\frac{\partial^2 <>}{\partial <> \partial <>}<>]], {
				i(1),
				i(2, "x"),
				i(3, "y"),
        d(4, get_visual)
			})
		),

		-- Integral
    -- El símbolo integral con el trigger "int" se encuentra en math_symbols.lua
		s({ trig = "oint", name = "integral cerrada", priority = 15 }, fmta([[\oint_{<>}<>]], { i(1),d(2, get_visual) })),
		s({ trig = "oiint", name = "integral cerrada doble", priority = 15 }, fmta([[\oiint_{<>}<>]], { i(1),d(2, get_visual) })),
		s({ trig = "oiiint", name = "integral cerrada triple", priority = 15 }, fmta([[\oiiint_{<>}<>]], { i(1),d(2, get_visual) })),
		s(
			{ trig = "uint", name = "integral unica", priority = 15 },
			fmta([[\int_{<>}^{<>}<> \, d<>]], { i(1), i(2), d(3, get_visual), i(4, "x") })
		),
		s(
			{ trig = "dint", name = "integral doble", priority = 15 },
			fmta(
				[[\int_{<>}^{<>}\int_{<>}^{<>}<> \, d<>d<>]],
				{ i(1), i(2), i(3), i(4), d(5, get_visual), i(6, "x"), i(7, "y") }
			)
		),
		s(
			{ trig = "tint", name = "integral triple", priority = 15 },
			fmta(
				[[\int_{<>}^{<>}\int_{<>}^{<>}\int_{<>}^{<>}<> \, d<>d<>d<>]],
				{ i(1), i(2), i(3), i(4), i(5), i(6), d(7, get_visual), i(8, "x"), i(9, "y"), i(10, "z") }
			)
		),
  }
  end

return M
