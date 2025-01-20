-- Autosnipped
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

function M.retrieve(is_math)
	local utils = require("luasnip-latex.utils.utils")
	local pipe, no_backslash = utils.pipe, utils.no_backslash

	local s_nb = ls.extend_decorator.apply(ls.snippet, {
		condition = pipe({ is_math, no_backslash }),
	})
	local s = ls.extend_decorator.apply(ls.snippet, {
		condition = pipe({ is_math }),
	})

	return {
		-- parse_snippet({ trig = "conj", name = "conjugate" }, "\\overline{$1}$0"),
		s({
			trig = "(\\?%a+)ovl",
			wordTrig = false,
			regTrig = true,
			name = "overline",
			priority = 10,
		}, {
			f(function(_, parent)
				return ("\\overline{%s}"):format(parent.captures[1])
			end),
			i(0),
		}),
		s_nb({ trig = "ovl", name = "big overline" }, fmta([[\overline{<>}<>]], { d(1, get_visual), i(0) })),

		s_nb({
			trig = "(%a+)und",
			wordTrig = false,
			regTrig = true,
			name = "underline",
			priority = 10,
		}, {
			f(function(_, parent)
				return ("\\underline{%s}"):format(parent.captures[1])
			end),
			i(0),
		}),
		s_nb({ trig = "und", name = "underline" }, fmta([[\underline{<>}<>]], { d(1, get_visual), i(0) })),

		s_nb({ trig = "XX", name = "cancel" }, fmta([[\cancel{<>}<>]], { d(1, get_visual), i(0) })),
		s_nb({ trig = "cup", name = "cancel to up" }, fmta([[\cancelto{<>}{<>}]], { i(1), d(2, get_visual) })),

		s_nb(
			{ trig = "UU", name = "Texto superior con llaves" },
			fmta([[\underbrace{<>}_{<>}]], { d(1, get_visual), i(2) })
		),
		s_nb(
			{ trig = "OO", name = "Texto inferior con llaves" },
			fmta([[\overbrace{<>}^{<>}]], { d(1, get_visual), i(2) })
		),
		s_nb(
			{ trig = "defu", name = "Texto inferior sin llaves (def under)" },
			fmta([[\underset{<>}{<>}]], { i(2), d(1, get_visual) })
		),
		s_nb(
			{ trig = "defo", name = "Texto superior sin llaves (def over)" },
			fmta([[\overset{<>}{<>}]], { i(2), d(1, get_visual) })
		),
		s({
			trig = "(\\?%a+)hat",
			wordTrig = false,
			regTrig = true,
			name = "hat",
			priority = 10,
		}, {
			f(function(_, parent)
				return ("\\hat{%s}"):format(parent.captures[1])
			end),
			i(0),
		}),
		s_nb({ trig = "hat", name = "hat" }, fmta([[\hat{<>}<>]], { d(1, get_visual), i(0) })),
		s_nb({
			trig = "(%a+)ora",
			wordTrig = false,
			regTrig = true,
			name = "over right arrow",
			desc = "flecha de vector, pero que se adapta mucho mejor",
			priority = 10,
		}, {
			f(function(_, parent)
				return ("\\overrightarrow{%s}"):format(parent.captures[1])
			end),
			i(0),
		}),
		s_nb({
			trig = "(%a+)ola",
			wordTrig = false,
			regTrig = true,
			name = "over left arrow",
			desc = "flecha de vector, pero que se adapta mucho mejor y va en dirección opuesta",
			priority = 10,
		}, {
			f(function(_, parent)
				return ("\\overleftarrow{%s}"):format(parent.captures[1])
			end),
			i(0),
		}),
		-- exponencial
		s({ trig = "xp", name = "^{}", wordTrig = false }, fmta("^{<>}<>", { i(1), i(0) })),
		s({ trig = "Xp", name = "xp with much power", wordTrig = false }, fmta("^{(<>)}<>", { i(1), i(0) })),
		s({ trig = "cb", name = "Cube ^3", wordTrig = false }, { t("^3") }),
		s({ trig = "cd", name = "Square ^2", wordTrig = false }, { t("^2") }),
		s({ trig = "sq", name = "square root", wordTrig = false }, fmta([[\sqrt{<>}<>]], { d(1, get_visual), i(0) })),
		s(
			{ trig = "Sq", name = "square root", wordTrig = false, priority = 10 },
			fmta([[\sqrt[<>]{<>}<>]], { i(1), d(2, get_visual), i(0) })
		),
		s({ trig = "inv", name = "inverse", wordTrig = false }, t("^{-1}")),
		--
		-- Lenguaje matemático
		s_nb({ trig = "EE", name = "exists" }, { t("\\exists") }),
		s_nb({ trig = "AA", name = "forall" }, { t("\\forall") }),
		s_nb({ trig = "&&", name = "land" }, { t("\\land") }),
		s_nb({ trig = "||", name = "lor" }, { t("\\lor") }),
		s_nb({ trig = "prop", name = "propto" }, { t("\\propto") }),
		-- subscript
		s_nb({ trig = "__", name = "subscript", wordTrig = false }, fmta("_{<>}<>", { i(1), i(0) })),
		s({
			trig = "(\\?%a+)__",
			wordTrig = false,
			regTrig = true,
			name = "subscript symbols",
			priority = 10,
		}, {
			f(function(_, parent)
				return ("%s_{"):format(parent.captures[1])
			end),
			i(0),
			t("}"),
		}),
		s_nb({ trig = "xnn", name = "x_n" }, { t("x_{n}") }),
		s_nb({ trig = "xnp", name = "x_n+1" }, { t("x_{n+1}") }),
		s_nb({ trig = "xmm", name = "x_m" }, { t("x_{m}") }),
		s_nb({ trig = "xmp", name = "x_m+1" }, { t("x_{m+1}") }),
		s_nb({ trig = "xii", name = "x_i" }, { t("x_{i}") }),
		s_nb({ trig = "xjj", name = "x_j" }, { t("x_{j}") }),

		s_nb({ trig = "ynn", name = "y_n" }, { t("x_{n}") }),
		s_nb({ trig = "ynp", name = "y_n+1" }, { t("y_{n+1}") }),
		s_nb({ trig = "ymm", name = "y_m" }, { t("y_{m}") }),
		s_nb({ trig = "yii", name = "y_i" }, { t("y_{i}") }),
		s_nb({ trig = "yjj", name = "y_j" }, { t("y_{j}") }),

		-- Set
		s_nb({ trig = "inn", name = "in" }, { t("\\in") }),
		s_nb({ trig = "!in", name = "not in", priority = 10 }, { t("\\not\\in") }),
		s_nb({ trig = "ss", name = "subset" }, { t("\\subset") }),
		s_nb({ trig = "set", name = "set" }, fmta([[\{<>\}<>]], { i(1), i(0) })),
		s_nb({ trig = "sm", name = "setminux", dscr = "Sacar un conjunto" }, { t("\\setminus") }),
		s_nb({ trig = "nn", name = "cap" }, { t("\\cap") }),
		s_nb(
			{ trig = "bnn", name = "bigcap", priority = 10 },
			fmta("\\bigcap_{<> \\in <>} <>", { i(1, "i"), i(2, "I"), i(0) })
		),
		s_nb({ trig = "uu", name = "cup" }, { t("\\cup") }),
		s_nb(
			{ trig = "buu", name = "bigcup", priority = 10 },
			fmta("\\bigcup_{<> \\in <>} <>", { i(1, "i"), i(2, "I"), i(0) })
		),
		s_nb({ trig = "!O", name = "emptyset" }, { t("\\emptyset") }),
		s({ trig = "comp", name = "complement" }, t("^{c}")),

		-- Arrow(flechas)
		s({ trig = "l-r", name = "leftrightarrow", priority = 20, wordTrig = false }, { t("\\leftrightarrow") }),
		s({ trig = "...", name = "ldots", priority = 10, wordTrig = false }, { t("\\ldots") }),
		s({ trig = "|.", name = "vdots", priority = 10, wordTrig = false }, { t("\\vdots") }),
		s({ trig = "/.", name = "ddots", priority = 10, wordTrig = false }, { t("\\ddots") }),
		s({ trig = "m-r", name = "mapsto", dscr = "flecha", priority = 20, wordTrig = false }, { t("\\mapsto") }),
		s({ trig = "-r", name = "to", priority = 10, wordTrig = false }, { t("\\to") }),

		-- Logic
		s_nb({ trig = "sii", name = "iff" }, { t("\\iff") }),

		s_nb({ trig = "dot", name = "dot" }, { t("\\dot{"), i(1), t("}") }),

		-- Derivate

		s_nb({ trig = "nabl", name = "nabla" }, { t("\\nabla") }),
		s_nb(
			{
				trig = "ddx",
				name = "d/dx",
			},
			fmta([[\frac{d<>}{d<>}<>]], {
				i(1),
				i(2, "x"),
				i(0),
			})
		),
		-- limites
		s_nb({ trig = "ooo", name = "infty" }, { t("\\infty") }),
		s_nb({ trig = "lim", name = "limites" }, fmta("\\lim_{<> \\to <>} <>", { i(1, "x"), i(2, "\\infty"), i(0) })),

		-- ESpacio
		s({ trig = ";;", name = "Separador ;", wordTrig = false }, { t("\\;") }),
		s({ trig = ",,", name = "Separador ,", wordTrig = false }, { t("\\,") }),
		-- Vec
		s_nb({ trig = "vec", name = "vector", wordTrig = false }, fmta([[\vec{<>}<>]], { i(1), i(0) })),
		--
		s_nb({ trig = "nrm", name = "norm" }, fmta("\\|<>\\|<>", { i(1), i(0) })),
		s_nb({ trig = "gg", name = "nombre", priority = 1000 }, { t("\\gg") }),
		s_nb({ trig = "<<", name = "<<" }, { t("\\ll ") }),
		s_nb({ trig = "txt", name = "text" }, fmta("\\text{<>}<>", { d(1, get_visual), i(0) })),
		s_nb(
			{ trig = "(%a)tbo", name = "text bold", wordTrig = false, regTrig = true, priority = 10 },
			fmta("<><>", {
				f(function(_, parent)
					return ("\\textbf{%s}"):format(parent.captures[1])
				end),
				i(0),
			})
		),
		s_nb({ trig = "tbo", name = "text bold" }, fmta("\\textbf{<>}<>", { d(1, get_visual), i(0) })),
		s(
			{ trig = "(\\?%a+)sbo", wordTrig = false, regTrig = true, name = "symbol bold", priority = 10 },
			fmta("<><>", {
				f(function(_, parent)
					return ("\\boldsymbol{%s}"):format(parent.captures[1])
				end),
				i(0),
			})
		),
		s({ trig = "sbo", name = "symbol bold" }, fmta("\\boldsymbol{<>}<>", { d(1, get_visual), i(0) })),

		s_nb(
			{ trig = "stxt", name = "text subscript", priority = 10 },
			fmta("_\\text{<>}<>", { d(1, get_visual), i(0) })
		),
		s_nb({ trig = "xx", name = "cross", wordTrig = false }, { t("\\times ") }),
		s_nb({ trig = "**", name = "cdot", priority = 10, wordTrig = false }, { t("\\cdot ") }),
		s_nb({ trig = ":=", name = "colon equals" }, { t("\\coloneqq ") }),
		s_nb({ trig = "RR", name = "Real Numbers" }, { t("\\mathbb{R}") }),
		s_nb({ trig = "CC", name = "Complex Numbers" }, { t("\\mathbb{C}") }),
		s_nb({ trig = "QQ", name = "Rational Numbers" }, { t("\\mathbb{Q}") }),
		s_nb({ trig = "ZZ", name = "Integers Numbers" }, { t("\\mathbb{Z}") }),
		s_nb({ trig = "NN", name = "Natural Numbers" }, { t("\\mathbb{N}") }),
		s_nb({ trig = "==", name = "equals", wordTrig = false }, fmta("&= <> \\\\", i(1))),
		s_nb({ trig = "!=", name = "not equals", wordTrig = false }, { t("\\neq") }),
		s_nb({ trig = "tons", name = "implies", wordTrig = false }, { t("\\implies") }),
		s_nb({ trig = "simp", name = "short implies", priority = 50 }, { t("\\Rightarrow") }),
		s_nb({ trig = "rimp", name = "implied by" }, t("\\impliedby")),
		s_nb({ trig = "<=", name = "less equal", wordTrig = false }, t("\\le")),
		s_nb({ trig = ">=", name = "greater equal", wordTrig = false }, t("\\ge")),
		s_nb({ trig = "~~", name = "~", wordTrig = false }, t("\\sim")),
		s_nb({ trig = "=~", name = "aproximacion", wordTrig = false }, t("\\approx")),
		--
		s_nb({ trig = "md", name = "mid" }, { t("\\mid ") }),
		s_nb({ trig = "abs", name = "absolute" }, fmta([[\lvert <> \rvert <>]], { d(1, get_visual), i(0) })),
		s_nb({ trig = "lll", name = "l" }, { t("\\ell ") }),

		-- Simbol
		s({ trig = "+-", name = "+-", wordTrig = false }, { t("\\pm") }),

		-- Integral
		s_nb({ trig = "oint", name = "integral", priority = 30 }, fmta([[\oint_{<>}]], { i(1) })),
		s_nb({ trig = "oiint", name = "integral", priority = 40 }, fmta([[\oiint_{<>}]], { i(1) })),
		s_nb({ trig = "oiiint", name = "integral", priority = 50 }, fmta([[\oiiint_{<>}]], { i(1) })),
		s_nb(
			{ trig = "uint", name = "integral", priority = 30 },
			fmta([[\int_{<>}^{<>}<> \, d<>]], { i(1), i(2), d(3, get_visual), i(4, "x") })
		),
		s_nb(
			{ trig = "dint", name = "integral doble", priority = 30 },
			fmta(
				[[\int_{<>}^{<>}\int_{<>}^{<>}<> \, d<>d<>]],
				{ i(1), i(2), i(3), i(4), d(5, get_visual), i(6, "x"), i(7, "y") }
			)
		),
		s_nb(
			{ trig = "tint", name = "integral triple", priority = 30 },
			fmta(
				[[\int_{<>}^{<>}\int_{<>}^{<>}\int_{<>}^{<>}<> \, d<>d<>d<>]],
				{ i(1), i(2), i(3), i(4), i(5), i(6), d(7, get_visual), i(8, "x"), i(9, "y"), i(10, "z") }
			)
		),
		-- Trigonometric
		s_nb({ trig = "sin", name = "sin", priority = 10 }, t("\\sin")),
		s_nb({ trig = "cos", name = "cos" }, t("\\cos")),
		s_nb({ trig = "tan", name = "tan" }, t("\\tan")),
		s_nb({ trig = "sec", name = "sec" }, t("\\sec")),
		s_nb({ trig = "csc", name = "csc" }, t("\\csc")),
		s_nb({ trig = "asin", name = "arcsin", priority = 20 }, t("\\arcsin")),
		s_nb({ trig = "acos", name = "arccin" }, t("\\arccos")),
		s_nb({ trig = "atan", name = "arctan" }, t("\\arctan")),
		s_nb({ trig = "asec", name = "arcsec" }, t("\\arcsec")),
		-- format
		s_nb(
			{ trig = "rm", name = "mathrm", wordTrig = false },
			fmta(
				[[
    \mathrm{<>}<>
    ]],
				{ d(1, get_visual), i(0) }
			)
		),
	}
end

return M
