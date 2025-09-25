local M = {}

local ls = require("luasnip")
-- local f = ls.function_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local i = ls.insert_node
local t = ls.text_node
local fmta = require("luasnip.extras.fmt").fmta

function M.retrieve(is_math)
	local utils = require("luasnip-latex.utils.utils")
	local pipe, no_backslash = utils.pipe, utils.no_backslash

	local s = ls.extend_decorator.apply(ls.snippet, {
		condition = pipe({ is_math }),
	})

  -- Función hecha por Gemini
	local generate_matrix_nodes = function(args)
		local dims = args[1][1]
		local rows, cols = dims:match("(%d+)(%d+)")
		if not (rows and cols) then
			return sn(nil, {})
		end

		rows = tonumber(rows)
		cols = tonumber(cols)

		local nodes = {}
		local placeholder_idx = 1
		for r = 1, rows do
			for c = 1, cols do
				table.insert(nodes, i(placeholder_idx, "0"))
				placeholder_idx = placeholder_idx + 1
				if c < cols then
					table.insert(nodes, t(" & "))
				end
			end
			if r < rows then
				table.insert(nodes, t(" \\\\ "))
			end
		end
		return sn(nil, nodes)
	end

	return {
		s(
			{ trig = "matc", name = "Matriz []" },
			fmta(
				[[
        \begin{bmatrix}
        <key2>
        \end{bmatrix}<key1>
        ]],
				{
					key1=i(1, "33"),
					key2=d(2, generate_matrix_nodes, { 1 })
				}
			)
		),
		s(
			{ trig = "matp", name = "Matriz ()" },
			fmta(
				[[
        \begin{pmatrix}
        <key2>
        \end{pmatrix}<key1>
        ]],
				{
					key1=i(1, "33"),
					key2=d(2, generate_matrix_nodes, { 1 })
				}
			)
		),
		s(
			{ trig = "mat|", name = "Matriz ||" },
			fmta(
				[[
        \begin{vmatrix}
        <key2>
        \end{vmatrix}<key1>
        ]],
				{
					key1=i(1, "33"),
					key2=d(2, generate_matrix_nodes, { 1 })
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
			{ trig = "matV", name = "Matriz vector general" },
			fmta(
				[[
  \begin{bmatrix}
    <a>_{11}\\
    \vdots \\
    <a>_{<n>1}
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
	}
end

return M
