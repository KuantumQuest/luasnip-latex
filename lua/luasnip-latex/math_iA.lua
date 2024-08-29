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

	local s_b = ls.extend_decorator.apply(ls.snippet, {
		condition = pipe({ is_math, no_backslash }),
	})
	local s = ls.extend_decorator.apply(ls.snippet, {
		condition = pipe({ is_math }),
	})

	return {
		-- parse_snippet({ trig = "conj", name = "conjugate" }, "\\overline{$1}$0"),
		s_b({
			trig = "(%a+)ovl",
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
		s_b({ trig = "ovl", name = "big overline" }, fmta([[\overline{<>}<>]], { d(1, get_visual), i(0) })),

		s_b({
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
		s_b({ trig = "und", name = "underline" }, fmta([[\underline{<>}<>]], { d(1, get_visual), i(0) })),

		s_b({
			trig = "(%a+)dot",
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
		s_b({
			trig = "(%a+)hat",
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
		s_b({ trig = "hat", name = "hat" }, fmta([[\hat{<>} <>]], { d(1, get_visual), i(0) })),
		s_b({
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
		s_b({
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
		s({ trig = "cp", name = "xp with much power", wordTrig = false }, fmta("^{(<>)}<>", { i(1), i(0) })),
		s({ trig = "cb", name = "Cube ^3", wordTrig = false }, { t("^3 ") }),
		s({ trig = "cd", name = "Square ^2", wordTrig = false }, { t("^2 ") }),
		s({ trig = "sq", name = "square root" }, fmta([[\sqrt{<>} <>]], { d(1, get_visual), i(0) })),
		s({ trig = "inv", name = "inverse", wordTrig = false }, t("^{-1}")),
		--
		s_b({ trig = "EE", name = "exists" }, { t("\\exists ") }),
		s_b({ trig = "AA", name = "forall" }, { t("\\forall ") }),
		-- subscript
		s_b({ trig = "__", name = "subscript", wordTrig = false }, fmta("_{<>}<>", { i(1), i(0) })),
		s_b({ trig = "xnn", name = "x_n" }, { t("x_{n}") }),
		s_b({ trig = "xnp", name = "x_n+1" }, { t("x_{n+1}") }),
		s_b({ trig = "xmm", name = "x_m" }, { t("x_{m}") }),
		s_b({ trig = "xmp", name = "x_m+1" }, { t("x_{m+1}") }),
		s_b({ trig = "xii", name = "x_i" }, { t("x_{i}") }),
		s_b({ trig = "xjj", name = "x_j" }, { t("x_{j}") }),

		s_b({ trig = "ynn", name = "y_n" }, { t("x_{n}") }),
		s_b({ trig = "yii", name = "y_i" }, { t("y_{i}") }),
		s_b({ trig = "yjj", name = "y_j" }, { t("y_{j}") }),

		-- Set
		s_b({ trig = "inn", name = "in" }, { t("\\in ") }),
		s_b({ trig = "nin", name = "not in", priority = 10 }, { t("\\not\\in ") }),
		s_b({ trig = "ss", name = "subset" }, { t("\\subset ") }),
		s_b({ trig = "set", name = "set" }, fmta([[\{ <> \} <>]], { i(1), i(0) })),
		s_b({ trig = "sm", name = "setminux", dscr = "Sacar un conjunto" }, { t("\\setminus ") }),
		s_b({ trig = "Nn", name = "cap" }, { t("\\cap ") }),
		s_b(
			{ trig = "bnn", name = "bigcap", priority = 10 },
			fmta("\\bigcap_{<> \\in <>} <>", { i(1, "i"), i(2, "I"), i(0) })
		),
		s_b({ trig = "Uu", name = "cup" }, { t("\\cup ") }),
		s_b(
			{ trig = "buu", name = "bigcup", priority = 10 },
			fmta("\\bigcup_{<> \\in <>} <>", { i(1, "i"), i(2, "I"), i(0) })
		),
		s_b({ trig = "OO", name = "emptyset" }, { t("\\O ") }),
		s_b({ trig = "cmp", name = "complement" }, t("^{c}")),

		-- Arrow(flechas)
		s_b({ trig = "l-r", name = "leftrightarrow", priority = 20 }, { t("\\leftrightarrow ") }),
		s_b({ trig = "...", name = "ldots", priority = 10 }, { t("\\ldots ") }),
		s_b({ trig = "m-r", name = "mapsto", dscr = "flecha" }, { t("\\mapsto ") }),
		s_b({ trig = "-r", name = "to", priority = 10 }, { t("\\to ") }),

		-- Logic
		s_b({ trig = "iff", name = "iff" }, { t("\\iff ") }),
		s_b({ trig = "siff", name = "shrot iff", priority = 10 }, { t("\\Leftrightarrow") }),

		-- Limits
		s_b({ trig = "ooo", name = "infty" }, { t("\\infty ") }),

		-- Derivate
		s_b({ trig = "nabl", name = "nabla" }, { t("\\nabla") }),

		--
		s_b({ trig = "nrm", name = "norm" }, fmta("\\|<>\\|<>", { i(1), i(0) })),
		s_b({ trig = ">>", name = ">>" }, { t("\\gg ") }),
		s_b({ trig = "<<", name = "<<" }, { t("\\ll ") }),
		s_b({ trig = "txt", name = "text" }, fmta("\\text{<>}<>", { d(1, get_visual), i(0) })),
		s_b(
			{ trig = "stxt", name = "text subscript", priority = 10 },
			fmta("_\\text{<>} <>", { d(1, get_visual), i(0) })
		),
		s_b({ trig = "xx", name = "cross" }, { t("\\times ") }),
		s_b({ trig = "**", name = "cdot", priority = 10 }, { t("\\cdot ") }),
		s_b({ trig = ":=", name = "colon equals" }, { t("\\coloneqq ") }),
		s_b({ trig = "RR", name = "Real Numbers" }, { t("\\mathbb{R} ") }),
		s_b({ trig = "QQ", name = "Rational Numbers" }, { t("\\mathbb{Q} ") }),
		s_b({ trig = "ZZ", name = "Integers Numbers" }, { t("\\mathbb{Z} ") }),
		s_b({ trig = "NN", name = "Natural Numbers" }, { t("\\mathbb{N} ") }),
		s_b({ trig = "==", name = "equals" }, fmta("&= <> \\\\", i(1))),
		s_b({ trig = "neq", name = "not equals" }, { t("\\neq ") }),
		s_b({ trig = "imp", name = "implies" }, t("\\implies ")),
		s_b({ trig = "simp", name = "short implies", priority = 50 }, t("\\Rightarrow")),
		s_b({ trig = "rimp", name = "implied by" }, t("\\impliedby ")),
		s_b({ trig = "leq", name = "less equal" }, t("\\le ")),
		s_b({ trig = "geq", name = "greater equal" }, t("\\ge ")),
		s_b({ trig = "~~", name = "~" }, t("\\sim ")),
		--
		s_b({ trig = "md", name = "mid" }, { t("\\mid ") }),
		s_b({ trig = "abs", name = "absolute" }, fmta([[\lvert <> \rvert <>]], { d(1, get_visual), i(0) })),
		s_b({ trig = "lll", name = "l" }, { t("\\ell ") }),
		s_b(
			{ trig = "fun", name = "function map" },
			fmta([[<>\colon <>\mathbb{R} \to <>\\mathbb{R}]], { i(1, "g"), i(2), i(3) })
		),

		-- Integral
		s_b(
			{ trig = "dint", name = "integral", priority = 30 },
			fmta([[\int_{<>}^{<>} <>]], { i(1, "\\infty"), i(2, "\\infty"), d(3, get_visual) })
		),

		-- Trigonometric
		s_b({ trig = "sin", name = "sin", priority = 10 }, t("\\sin")),
		s_b({ trig = "cos", name = "cos" }, t("\\cos")),
		s_b({ trig = "tan", name = "tan" }, t("\\tan")),
		s_b({ trig = "sec", name = "sec" }, t("\\sec")),
		s_b({ trig = "csc", name = "csc" }, t("\\csc")),
		s_b({ trig = "asin", name = "arcsin", priority = 20 }, t("\\arcsin")),
		s_b({ trig = "acos", name = "arcsin" }, t("\\arccos")),
		s_b({ trig = "atan", name = "arctan" }, t("\\arctan")),
		s_b({ trig = "asec", name = "arcsec" }, t("\\arcsec")),
		-- format
		s_b({ trig = "sin", name = "sin", priority = 10 }, t("\\sin")),
	}
end

return M
