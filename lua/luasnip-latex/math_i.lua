local M = {}

local ls = require("luasnip")
local utils = require("luasnip-latex.utils.utils")
local pipe = utils.pipe

function M.retrieve(is_math)
	local s = ls.extend_decorator.apply(ls.snippet, {
		wordTrig = false,
		condition = pipe({ is_math }), -- Esta variable es una función compuesta!
		-- show_condition = is_math,
	})
	local fmta = require("luasnip.extras.fmt").fmta
	local t = ls.text_node
	local i = ls.insert_node
	local d = ls.dynamic_node
	local f = ls.function_node
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
			fmta("\\sum_{<>=<>}^{<>}<>", {
				i(1, "n"),
				i(2, "1"),
				i(3, "\\infty"),
				d(4, get_save_text, {}),
			})
		),
		s(
			{
				trig = "tay",
				name = "taylor",
			},
			fmta("\\sum_{<>=<>}^{<>} \\frac{<>^{(<>)}(<>)\\mid_{<>=<>}}{<>!} (x-<>)^{<>}<>", {
				i(1, "n"),
				i(2, "0"),
				i(3, "\\infty"),
				i(4, "f"),
				rep(1),
				i(5, "x"),
				rep(5),
				i(6, "x_0"),
				rep(1),
				rep(6),
				rep(1),
				i(0),
			}),
			{
				repeat_duplicates = true,
			}
		),
		s(
			{
				trig = "prod",
				name = "product",
			},
			fmta("\\prod_{<>=<>}^{<>}<>", {
				i(1, "n"),
				i(2, "1"),
				i(3, "\\infty"),
				d(4, get_save_text, {}),
			})
		),
		s(
			{
				trig = "par",
				name = "Derivada parcial",
				desc = "Derivada parcial en modo función (df/dx)",
			},
			fmta([[\frac{\partial <>}{\partial <>}<>]], {
				i(1),
				i(2, "x"),
				i(3),
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
				i(3),
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
				i(4),
			})
		),
		s(
			{
				trig = "b(",
				name = "left( right)",
			},
			fmta([[\left( <> \right)<>]], {
				d(1, get_save_text, {}),
				i(0),
			})
		),
		s(
			{
				trig = "b|",
				name = "left| right|",
			},
			fmta([[\left| <> \right|<>]], {
				d(1, get_save_text, {}),
				i(0),
			})
		),
		s(
			{
				trig = "bN",
				name = "left|| right||",
			},
			fmta([[\left\| <> \right\|<>]], {
				d(1, get_save_text, {}),
				i(0),
			})
		),
		s(
			{
				trig = "bs",
				name = "left{ right}",
			},
			fmta([[\left\{ <> \right\}<>]], {
				d(1, get_save_text, {}),
				i(0),
			})
		),
		s(
			{
				trig = "b[",
				name = "left[ right]",
			},
			fmta([[\left[ <> \right]<>]], {
				d(1, get_save_text, {}),
				i(0),
			})
		),
		s(
			{
				trig = "b<",
				name = "left< right>",
			},
			fmta([[\left<< <> \right>><>]], {
				d(1, get_save_text, {}),
				i(0),
			})
		),
		s(
			{
				trig = "a<",
				name = "< >",
			},
			fmta([[\langle <> \rangle <>]], {
				d(1, get_save_text, {}),
				i(0),
			})
		),
		s(
			{
				trig = "seq",
				name = "Sequence (series)",
			},
			fmta([[\left({<>}_{<>}\right)_{<>=<>}^{<>}<>]], {
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
		-- Derivada: Newton notation
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
		--
		s(
			{ trig = "fun", name = "function map", wordTrig = false },
			fmta([[<>\colon <>\mathbb{R} \to <>\mathbb{R}]], { i(1, "g"), i(2), i(3) })
		),
		s(
			{ trig = "mat[", name = "matriz de tipo []" },
			fmta(
				[[
      \begin{bmatrix}
        <>
      \end{bmatrix}<>
      ]],
				{
					i(1),
					i(0),
				}
			)
		),
		s(
			{ trig = "mat|", name = "matriz de tipo ||" },
			fmta(
				[[
      \begin{vmatrix}
        <>
      \end{vmatrix}<>
      ]],
				{
					i(1),
					i(0),
				}
			)
		),
		s(
			{ trig = "mat(", name = "matriz de tipo ()" },
			fmta(
				[[
      \begin{pmatrix}
        <>
      \end{pmatrix}<>
      ]],
				{
					i(1),
					i(0),
				}
			)
		),
		s(
			{ trig = "matG", name = "Matriz general" },
			fmta(
				[[
  \begin{bmatrix}
    <a>_{11} & \ldots & <a>_{1<p>}\\
    \vdots & \ddots & \vdots\\
    <a>_{<n>1} & \ldots & <a>_{<n><p>}
  \end{bmatrix}
      ]],
				{
					a = i(1),
					n = i(2),
					p = i(3),
				},
				{
					repeat_duplicates = true,
				}
			)
		),
		s(
			{ trig = "matI", name = "Matriz Identidad 33" },
			fmta(
				[[
\begin{bmatrix}
  <a> & 0 & 0\\
  0 & <b> & 0\\
  0 & 0 & <c>
\end{bmatrix}
      ]],
				{
					a = i(1),
					b = i(2),
					c = i(3),
				}
			)
		),
		s(
			{ trig = "mat31", name = "Matriz 31" },
			fmta(
				[[
\begin{bmatrix}
  <a>\\
  <b>\\
  <c>
\end{bmatrix}
      ]],
				{
					a = i(1, "0"),
					b = i(2, "0"),
					c = i(3, "0"),
				}
			)
		),
		s(
			{ trig = "mat21", name = "Matriz 21" },
			fmta(
				[[
\begin{bmatrix}
  <a>\\
  <b>
\end{bmatrix}
      ]],
				{
					a = i(1, "0"),
					b = i(2, "0"),
				}
			)
		),
		s(
			{ trig = "mat41", name = "Matriz 41" },
			fmta(
				[[
\begin{bmatrix}
  <a>\\
  <b>\\
  <c>\\
  <d>
\end{bmatrix}
      ]],
				{
					a = i(1, "0"),
					b = i(2, "0"),
					c = i(3, "0"),
					d = i(4, "0"),
				}
			)
		),
		s(
			{ trig = "matV", name = "Matriz vector", priority = 20 },
			fmta(
				[[
\begin{bmatrix}
  <a>_{1}\\
  \vdots\\
  <a>_{<n>}
\end{bmatrix}
      ]],
				{
					a = i(1),
					n = i(2),
				},
				{
					repeat_duplicates = true,
				}
			)
		),
		s(
			{ trig = "mat22", name = "Matriz 22" },
			fmta(
				[[
\begin{bmatrix}
  <> & <>\\
  <> & <>
\end{bmatrix}
      ]],
				{
					i(1, "0"),
					i(2, "0"),
					i(3, "0"),
					i(4, "0"),
				}
			)
		),
		s(
			{ trig = "mat23", name = "Matriz 23" },
			fmta(
				[[
\begin{bmatrix}
  <> & <> & <>\\
  <> & <> & <>
\end{bmatrix}
      ]],
				{
					i(1, "0"),
					i(2, "0"),
					i(3, "0"),
					i(4, "0"),
					i(5, "0"),
					i(6, "0"),
				}
			)
		),
		s(
			{ trig = "mat32", name = "Matriz 32" },
			fmta(
				[[
\begin{bmatrix}
  <> & <>\\
  <> & <>\\
  <> & <>
\end{bmatrix}
      ]],
				{
					i(1, "0"),
					i(2, "0"),
					i(3, "0"),
					i(4, "0"),
					i(5, "0"),
					i(6, "0"),
				}
			)
		),
		s(
			{ trig = "mat33", name = "Matriz 33" },
			fmta(
				[[
\begin{bmatrix}
  <> & <> & <>\\
  <> & <> & <>\\
  <> & <> & <>
\end{bmatrix}
      ]],
				{
					i(1, "0"),
					i(2, "0"),
					i(3, "0"),
					i(4, "0"),
					i(5, "0"),
					i(6, "0"),
					i(7, "0"),
					i(8, "0"),
					i(9, "0"),
				}
			)
		),
		s(
			{ trig = "mat34", name = "Matriz 34" },
			fmta(
				[[
\begin{bmatrix}
  <> & <> & <> & <>\\
  <> & <> & <> & <>\\
  <> & <> & <> & <>
\end{bmatrix}
      ]],
				{
					i(1, "0"),
					i(2, "0"),
					i(3, "0"),
					i(4, "0"),
					i(5, "0"),
					i(6, "0"),
					i(7, "0"),
					i(8, "0"),
					i(9, "0"),
					i(10, "0"),
					i(11, "0"),
					i(12, "0"),
				}
			)
		),
		s(
			{ trig = "mat44", name = "Matriz 44" },
			fmta(
				[[
\begin{bmatrix}
  <> & <> & <> & <>\\
  <> & <> & <> & <>\\
  <> & <> & <> & <>\\
  <> & <> & <> & <>
\end{bmatrix}
      ]],
				{
					i(1, "0"),
					i(2, "0"),
					i(3, "0"),
					i(4, "0"),
					i(5, "0"),
					i(6, "0"),
					i(7, "0"),
					i(8, "0"),
					i(9, "0"),
					i(10, "0"),
					i(11, "0"),
					i(12, "0"),
					i(13, "0"),
					i(14, "0"),
					i(15, "0"),
					i(16, "0"),
				}
			)
		),
		s(
			{ trig = "mat43", name = "Matriz 43" },
			fmta(
				[[
\begin{bmatrix}
  <> & <> & <>\\
  <> & <> & <>\\
  <> & <> & <>\\
  <> & <> & <>
\end{bmatrix}
      ]],
				{
					i(1, "0"),
					i(2, "0"),
					i(3, "0"),
					i(4, "0"),
					i(5, "0"),
					i(6, "0"),
					i(7, "0"),
					i(8, "0"),
					i(9, "0"),
					i(10, "0"),
					i(11, "0"),
					i(12, "0"),
				}
			)
		),
		s(
			{ trig = "mat42", name = "Matriz 42" },
			fmta(
				[[
\begin{bmatrix}
  <> & <>\\
  <> & <>\\
  <> & <>\\
  <> & <>
\end{bmatrix}
      ]],
				{
					i(1, "0"),
					i(2, "0"),
					i(3, "0"),
					i(4, "0"),
					i(5, "0"),
					i(6, "0"),
					i(7, "0"),
					i(8, "0"),
				}
			)
		),
	}
end
return M
