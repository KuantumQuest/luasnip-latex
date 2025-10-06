local M = {}

local ls = require("luasnip")
local f = ls.function_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local i = ls.insert_node
local t = ls.text_node
local fmta = require("luasnip.extras.fmt").fmta
local get_visual = require("luasnip-latex.utils.utils").get_visual

function M.retrieve(is_math)
	local utils = require("luasnip-latex.utils.utils")
	local pipe, no_backslash = utils.pipe, utils.no_backslash

	-- local s_nb = ls.extend_decorator.apply(ls.snippet, {
	-- 	condition = pipe({ is_math, no_backslash }),
	-- }) --funciona cuando no hay backslash
	local s = ls.extend_decorator.apply(ls.snippet, {
		condition = pipe({ is_math }),
	})

	local rep = require("luasnip.extras").rep

	return {
    -- Formating
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

		s(
			{ trig = "UU", name = "Texto superior con llaves" },
			fmta([[\underbrace{<>}_{<>}]], { d(1, get_visual), i(2) })
		),
		s(
			{ trig = "OO", name = "Texto inferior con llaves" },
			fmta([[\overbrace{<>}^{<>}]], { d(1, get_visual), i(2) })
		),
		s(
			{ trig = "defu", name = "Texto inferior sin llaves (def under)" },
			fmta([[\underset{<>}{<>}]], { i(2), d(1, get_visual) })
		),
		s(
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
		s({ trig = "hat", name = "hat" }, fmta([[\hat{<>}<>]], { d(1, get_visual), i(0) })),
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
			trig = "ora",
			name = "over right arrow",
			desc = "flecha de vector, pero que se adapta mucho mejor",
		},
      fmta([[\overrightarrow{<>}<>]], {d(1,get_visual), i(0)})
    ),
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
		s({
			trig = "ola",
			name = "over left arrow",
			desc = "flecha de vector, pero que se adapta mucho mejor",
		},
      fmta([[\overleftarrow{<>}<>]], {d(1,get_visual), i(0)})
    ),
		s({ trig = "__", name = "subscript", wordTrig = false }, fmta("_{<>}<>", { i(1), i(0) })),
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
		s(
			{ trig = "stxt", name = "text subscript", wordTrig=false },
			fmta("_\\text{<>}<>", { d(1, get_visual), i(0) })
		),
		s({ trig = "tbo", name = "text bold" }, fmta("\\textbf{<>}", { d(1, get_visual)})),
		s(
			{ trig = "(\\?%a+)sbo", wordTrig = false, regTrig = true, name = "symbol bold"},
			fmta("<><>", {
				f(function(_, parent)
					return ("\\boldsymbol{%s}"):format(parent.captures[1])
				end),
				i(0),
			})
		),
		s({ trig = "sbo", name = "symbol bold" }, fmta("\\boldsymbol{<>}", { d(1, get_visual)})),

		s({ trig = "rm", name = "mathrm"}, fmta([[\mathrm{<>}]],{ d(1, get_visual)})),
    s({ trig= "bx", name= "boxed"}, fmta([[\boxed{<>}]],{d(1,get_visual)})),

    -- Cancel

		s({ trig = "XX", name = "cancel" }, fmta([[\cancel{<>}]], { d(1, get_visual)})),
		s({ trig = "cup", name = "cancel to up" }, fmta([[\cancelto{<>}{<>}]], { i(1), d(2, get_visual) })),

		-- Math Lenguage
		s({ trig = "sii", name = "iff" }, { t("\\iff") }),
		s({ trig = "EE", name = "exists" }, { t("\\exists") }),
		s({ trig = "AA", name = "forall" }, { t("\\forall") }),
		s({ trig = "&&", name = "land" }, { t("\\land") }),
		s({ trig = "||", name = "lor" }, { t("\\lor") }),
		s({ trig = "prop", name = "propto" }, { t("\\propto") }),

		s({ trig = ":=", name = "colon equals" }, { t("\\coloneqq ") }),
		s({ trig = "RR", name = "Real Numbers" }, { t("\\mathbb{R}") }),
		s({ trig = "CC", name = "Complex Numbers" }, { t("\\mathbb{C}") }),
		s({ trig = "QQ", name = "Rational Numbers" }, { t("\\mathbb{Q}") }),
		s({ trig = "ZZ", name = "Integers Numbers" }, { t("\\mathbb{Z}") }),
		s({ trig = "NN", name = "Natural Numbers" }, { t("\\mathbb{N}") }),
		s({ trig = "imp", name = "implies"}, { t("\\implies") }),
		s({ trig = "simp", name = "short implies"}, { t("\\Rightarrow") }),
		s({ trig = "rimp", name = "implied by" }, t("\\impliedby")),

		-- Index
		s({ trig = "xnn", name = "x_n" }, { t("x_{n}") }),
		s({ trig = "xnp", name = "x_n+1" }, { t("x_{n+1}") }),
		s({ trig = "xmm", name = "x_m" }, { t("x_{m}") }),
		s({ trig = "xmp", name = "x_m+1" }, { t("x_{m+1}") }),
		s({ trig = "xii", name = "x_i" }, { t("x_{i}") }),
		s({ trig = "xjj", name = "x_j" }, { t("x_{j}") }),

		s({ trig = "ynn", name = "y_n" }, { t("x_{n}") }),
		s({ trig = "ynp", name = "y_n+1" }, { t("y_{n+1}") }),
		s({ trig = "ymm", name = "y_m" }, { t("y_{m}") }),
		s({ trig = "yii", name = "y_i" }, { t("y_{i}") }),
		s({ trig = "yjj", name = "y_j" }, { t("y_{j}") }),

		-- Set
		s({ trig = "inn", name = "in" }, { t("\\in") }),
		s({ trig = "!in", name = "not in", priority = 10 }, { t("\\not\\in") }),
		s({ trig = "ss", name = "subset" }, { t("\\subset") }),
		s({ trig = "set", name = "set" }, fmta([[\{<>\}<>]], { i(1), i(0) })),
		s({ trig = "sm", name = "setminux", dscr = "Sacar un conjunto" }, { t("\\setminus") }),
		s({ trig = "nn", name = "cap" }, { t("\\cap") }),
		s({ trig = "uu", name = "cup" }, { t("\\cup") }),
		s({ trig = "comp", name = "complement", wordTrig= false }, t("^{c}")),
		s(
			{ trig = "bnn", name = "bigcap", priority = 10 },
			fmta("\\bigcap_{<> \\in <>} <>", { i(1, "i"), i(2, "I"), d(3,get_visual)})
		),
		s(
			{ trig = "buu", name = "bigcup", priority = 10 },
			fmta("\\bigcup_{<> \\in <>} <>", { i(1, "i"), i(2, "I"), d(3,get_visual)})
		),
		s({ trig = "!O", name = "emptyset" }, { t("\\emptyset") }),

		-- Arrow(flechas)
		s({ trig = "l-r", name = "leftrightarrow"}, { t("\\leftrightarrow") }),
		s({ trig = "...", name = "ldots"}, { t("\\ldots") }),
		s({ trig = "|.", name = "vdots"}, { t("\\vdots") }),
		s({ trig = "/.", name = "ddots"}, { t("\\ddots") }),
		s({ trig = "m-r", name = "mapsto", dscr = "flecha"}, { t("\\mapsto") }),
		s({ trig = "-r", name = "to"}, { t("\\to") }),

		-- Operations
		s({ trig = "xx", name = "cross", wordTrig = false }, { t("\\times") }),
		s({ trig = "**", name = "cdot", priority = 10, wordTrig = false }, { t("\\cdot") }),

		s({ trig = "+-", name = "+-"}, { t("\\pm") }),
		s({ trig = "-+", name = "-+"}, { t("\\mp") }),

		s({ trig = "==", name = "equals"}, fmta("&= <> \\\\", i(1))),
		s({ trig = "!=", name = "not equals"}, { t("\\neq") }),
		s({ trig = "<=", name = "less equal"}, t("\\le")),
		s({ trig = ">=", name = "greater equal"}, t("\\ge")),
		s({ trig = "~~", name = "~"}, t("\\sim")),
		s({ trig = "=~", name = "aproximacion"}, t("\\approx")),

		s({trig = "sum", name = "sumatorio",}, fmta("\\sum_{<>=<>}^{<>}<>", {
			i(1, "n"), i(2, "1"), i(3, "\\infty"), d(4, get_visual),})),
		s( { trig = "tay", name = "taylor", },
			fmta("\\sum_{<>=<>}^{<>} \\frac{<>^{(<>)}(<>)\\mid_{<>=<>}}{<>!} (x-<>)^{<>}", {
				i(1, "n"), i(2, "0"),
				i(3, "\\infty"), i(4, "f"),
				rep(1), i(5, "x"),
				rep(5), i(6, "x_0"),
				rep(1), rep(6),
				rep(1),
			}), {repeat_duplicates = true,}),

		s({ trig = "xp", name = "^{}", wordTrig = false }, fmta("^{<>}", { d(1,get_visual) })),
		s({ trig = "Xp", name = "xp with much power", wordTrig = false }, fmta("^{(<>)}", { d(1,get_visual)})),
		s({ trig = "cb", name = "Cube ^3", wordTrig = false }, { t("^3") }),
		s({ trig = "cd", name = "Square ^2", wordTrig = false }, { t("^2") }),
		s({ trig = "sq", name = "square root"}, fmta([[\sqrt{<>}<>]], { d(1, get_visual), i(0) })),
		s(
			{ trig = "Sq", name = "square root"},
			fmta([[\sqrt[<>]{<>}]], { i(1), d(2, get_visual)})
		),
		s({ trig = "inv", name = "inverse", wordTrig = false }, t("^{-1}")),

		s( {trig = "prod", name = "product",},
			fmta("\\prod_{<>=<>}^{<>}<>", {
				i(1, "n"), i(2, "1"),
				i(3, "\\infty"), d(4, get_visual),})),

		-- Espacio
		s({ trig = ";;", name = "Separador ;" }, { t("\\;") }),
		s({ trig = ",,", name = "Separador ," }, { t("\\,") }),

    -- Math env
		s({ trig = "ali", name = "Aligned" },
			fmta(
				[[
        \begin{aligned}
        <>
        \end{aligned}
        ]],
				{ d(1, get_visual) })),
		s( { trig = "bigfun", name = "Big function" },
			fmta(
				[[
          \begin{aligned}
          <>: <> &\longrightarrow <> \\
          <> &\longmapsto <> 
          \end{aligned}
        ]],
				{ i(1, "f"), i(2), i(3), i(4), i(5), }) ),
		s(
			{ trig = "case", name = "Cases" },
			fmta(
				[[
        \begin{cases}
        <>
        \end{cases}
        ]],
				{ i(1) }) ),
		s(
			{ trig = "beg", name = "environment" },
			fmta(
				[[
        \begin{<key1>}
        <>
        \end{<key1>}
        ]],
				{key1 = i(1), d(2, get_visual) }, { repeat_duplicates = true,})),

		-- Trigonometric
		s({ trig = "sin", name = "sin"}, t("\\sin")),
		s({ trig = "cos", name = "cos" }, t("\\cos")),
		s({ trig = "tan", name = "tan" }, t("\\tan")),
		s({ trig = "sec", name = "sec" }, t("\\sec")),
		s({ trig = "csc", name = "csc" }, t("\\csc")),
		s({ trig = "asin", name = "arcsin"}, t("\\arcsin")),
		s({ trig = "acos", name = "arccin" }, t("\\arccos")),
		s({ trig = "atan", name = "arctan" }, t("\\arctan")),
		s({ trig = "asec", name = "arcsec" }, t("\\arcsec")),

    -- Open-Close
		s({trig = "bp", name = "left( right)", }, fmta([[\left( <> \right)<>]], { d(1, get_visual, {}), i(0), })),
		s({trig = "b|", name = "left| right|", },
			fmta([[\left| <> \right|]], {
				d(1, get_visual),})),
		s({trig = "bN", name = "left|| right||", },
			fmta([[\left\| <> \right\|]], {
				d(1, get_visual, {}),})),
		s(
			{trig = "bs", name = "left{ right}",},
			fmta([[\left\{ <> \right\}]], {
				d(1, get_visual, {}), })),
		s({trig = "bc", name = "left[ right]", },
			fmta([[\left[ <> \right]<>]], {
				d(1, get_visual, {}), i(0), })),
		s({trig = "b<", name = "left< right>", },
			fmta([[\left<< <> \right>>]], { d(1, get_visual, {}),})),
		s({trig = "a<", name = "< >", },
			fmta([[\langle <> \rangle]], { d(1, get_visual, {}), })),

		-- Others
		s({ trig = "vec", name = "vector"}, fmta([[\vec{<>}]], { i(1) })),
		s({ trig = "nrm", name = "norm" }, fmta("\\|<>\\|", {d(1,get_visual)})),
		s({ trig = "gg", name = ">>"}, { t("\\gg") }), s({ trig = "ll", name = "<<" }, { t("\\ll") }),
		s({ trig = "txt", name = "text" }, fmta("\\text{<>}", {d(1, get_visual)})),
		s(
			{ trig = "(%a)tbo", name = "text bold", wordTrig = false, regTrig = true, priority = 10 },
			fmta("<><>", {
				f(function(_, parent)
					return ("\\textbf{%s}"):format(parent.captures[1])
				end),
				i(0),
			})
		),
		s({ trig = "md", name = "mid" }, { t("\\mid") }),
		s({ trig = "abs", name = "absolute" }, fmta([[\lvert <> \rvert]], { d(1, get_visual) })),
	}
end

return M
