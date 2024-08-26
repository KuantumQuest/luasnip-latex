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

	local decorator = {
		condition = pipe({ is_math, no_backslash }),
	}

	local s = ls.extend_decorator.apply(ls.snippet, decorator) --[[@as function]]

	return {
		-- parse_snippet({ trig = "conj", name = "conjugate" }, "\\overline{$1}$0"),
		s({
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
		s({ trig = "ovl", name = "big overline" }, fmta([[\overline{<>}<>]], { d(1, get_visual), i(0) })),

		s({
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
		s({ trig = "und", name = "underline" }, fmta([[\underline{<>}<>]], { d(1, get_visual), i(0) })),

		s({
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
		s({
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
		s({ trig = "hat", name = "hat" }, fmta([[\hat{<>} <>]], { d(1, get_visual), i(0) })),
		s({
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
		s({
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
		s({ trig = "EE", name = "exists" }, { t("\\exists ") }),
		s({ trig = "AA", name = "forall" }, { t("\\forall ") }),
		-- subscript
		s({ trig = "__", name = "subscript", wordTrig = false }, fmta("_{<>}<>", { i(1), i(0) })),
		s({ trig = "xnn", name = "x_n" }, { t("x_{n}") }),
		s({ trig = "xnp", name = "x_n+1" }, { t("x_{n+1}") }),
		s({ trig = "xmm", name = "x_m" }, { t("x_{m}") }),
		s({ trig = "xmp", name = "x_m+1" }, { t("x_{m+1}") }),
		s({ trig = "xii", name = "x_i" }, { t("x_{i}") }),
		s({ trig = "xjj", name = "x_j" }, { t("x_{j}") }),

		s({ trig = "ynn", name = "y_n" }, { t("x_{n}") }),
		s({ trig = "yii", name = "y_i" }, { t("y_{i}") }),
		s({ trig = "yjj", name = "y_j" }, { t("y_{j}") }),

		-- Set
		s({ trig = "inn", name = "in" }, { t("\\in ") }),
		s({ trig = "nin", name = "not in", priority = 10 }, { t("\\not\\in ") }),
		s({ trig = "ss", name = "subset" }, { t("\\subset ") }),
		s({ trig = "set", name = "set" }, fmta([[\{ <> \} <>]], { i(1), i(0) })),
		s({ trig = "sm", name = "setminux", dscr = "Sacar un conjunto" }, { t("\\setminus ") }),
		s({ trig = "Nn", name = "cap" }, { t("\\cap ") }),
		s(
			{ trig = "bnn", name = "bigcap", priority = 10 },
			fmta("\\bigcap_{<> \\in <>} <>", { i(1, "i"), i(2, "I"), i(0) })
		),
		s({ trig = "Uu", name = "cup" }, { t("\\cup ") }),
		s(
			{ trig = "buu", name = "bigcup", priority = 10 },
			fmta("\\bigcup_{<> \\in <>} <>", { i(1, "i"), i(2, "I"), i(0) })
		),
		s({ trig = "OO", name = "emptyset" }, { t("\\O ") }),
		s({ trig = "cmp", name = "complement" }, t("^{c}")),

		-- Arrow(flechas)
		s({ trig = "l-r", name = "leftrightarrow", priority = 20 }, { t("\\leftrightarrow ") }),
		s({ trig = "...", name = "ldots", priority = 10 }, { t("\\ldots ") }),
		s({ trig = "m-r", name = "mapsto", dscr = "flecha" }, { t("\\mapsto ") }),
		s({ trig = "-r", name = "to", priority = 10 }, { t("\\to ") }),

		-- Logic
		s({ trig = "iff", name = "iff" }, { t("\\iff ") }),
		s({ trig = "siff", name = "shrot iff", priority = 10 }, { t("\\Leftrightarrow") }),

		-- Limits
		s({ trig = "ooo", name = "infty" }, { t("\\infty ") }),

		-- Derivate
		s({ trig = "nabl", name = "nabla" }, { t("\\nabla") }),

		--
		s({ trig = "nrm", name = "norm" }, fmta("\\|<>\\|<>", { i(1), i(0) })),
		s({ trig = ">>", name = ">>" }, { t("\\gg ") }),
		s({ trig = "<<", name = "<<" }, { t("\\ll ") }),
		s({ trig = "txt", name = "text" }, fmta("\\text{<>}<>", { d(1, get_visual), i(0) })),
		s(
			{ trig = "stxt", name = "text subscript", priority = 10 },
			fmta("_\\text{<>} <>", { d(1, get_visual), i(0) })
		),
		s({ trig = "xx", name = "cross" }, { t("\\times ") }),
		s({ trig = "**", name = "cdot", priority = 10 }, { t("\\cdot ") }),
		s({ trig = ":=", name = "colon equals" }, { t("\\coloneqq ") }),
		s({ trig = "RR", name = "Real Numbers" }, { t("\\mathbb{R} ") }),
		s({ trig = "QQ", name = "Rational Numbers" }, { t("\\mathbb{Q} ") }),
		s({ trig = "ZZ", name = "Integers Numbers" }, { t("\\mathbb{Z} ") }),
		s({ trig = "NN", name = "Natural Numbers" }, { t("\\mathbb{N} ") }),
		s({ trig = "==", name = "equals" }, fmta("&= <> \\\\", i(1))),
		s({ trig = "neq", name = "not equals" }, { t("\\neq ") }),
		s({ trig = "imp", name = "implies" }, t("\\implies ")),
		s({ trig = "simp", name = "short implies", priority = 50 }, t("\\Rightarrow")),
		s({ trig = "rimp", name = "implied by" }, t("\\impliedby ")),
		s({ trig = "leq", name = "less equal" }, t("\\le ")),
		s({ trig = "geq", name = "greater equal" }, t("\\ge ")),
		s({ trig = "~~", name = "~" }, t("\\sim ")),
		--
		s({ trig = "md", name = "mid" }, { t("\\mid ") }),
		s({ trig = "abs", name = "absolute" }, fmta([[\lvert <> \rvert <>]], { d(1, get_visual), i(0) })),
		s({ trig = "lll", name = "l" }, { t("\\ell ") }),
		s(
			{ trig = "fun", name = "function map" },
			fmta([[<>\colon <>\mathbb{R} \to <>\\mathbb{R}]], { i(1, "g"), i(2), i(3) })
		),

		-- Integral
		s(
			{ trig = "dint", name = "integral", priority = 30 },
			fmta([[\int_{<>}^{<>} <>]], { i(1, "\\infty"), i(2, "\\infty"), d(3, get_visual) })
		),

		-- Trigonometric
		s({ trig = "sin", name = "sin", priority = 10 }, t("\\sin")),
		s({ trig = "cos", name = "cos" }, t("\\cos")),
		s({ trig = "tan", name = "tan" }, t("\\tan")),
		s({ trig = "sec", name = "sec" }, t("\\sec")),
		s({ trig = "csc", name = "csc" }, t("\\csc")),
		s({ trig = "asin", name = "arcsin", priority = 20 }, t("\\arcsin")),
		s({ trig = "acos", name = "arcsin" }, t("\\arccos")),
		s({ trig = "atan", name = "arctan" }, t("\\arctan")),
		s({ trig = "asec", name = "arcsec" }, t("\\arcsec")),
	}
end

return M
