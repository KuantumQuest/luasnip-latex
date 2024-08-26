local ls = require("luasnip")
local t = ls.text_node
local i = ls.insert_node
local sn = ls.snippet_node
local d = ls.dynamic_node
local fmta = require("luasnip.extras.fmt").fmta

local get_visual = function(_, parent)
	local text = parent.snippet.env.LS_SELECT_DEDENT
	if #text > 0 then
		return sn(nil, { i(1, text) })
	else
		return sn(nil, { i(1) })
	end
end

local M = {}

function M.retrieve(not_math)
	local utils = require("luasnip-latex.utils.utils")
	local pipe = utils.pipe

	local conds = require("luasnip.extras.expand_conditions")
	local condition = pipe({ conds.line_begin, not_math })
	local s = ls.extend_decorator.apply(ls.snippet, {
		condition = condition,
	}) --[[@as function]]
	return {
		s(
			{ trig = "ali", name = "Align" },
			fmta(
				[[
      \begin{align}
        <>
      \end{align}
      <>
      ]],
				{
					i(1),
					i(0),
				}
			)
		),
		s(
			{ trig = "case", name = "Cases" },
			fmta(
				[[
      \begin{cases}
        <>
      \end{cases}
      <>
      ]],
				{
					i(1),
					i(0),
				}
			)
		),
		s(
			{ trig = "beg", name = "environment" },
			fmta(
				[[
      \begin{<key1>}
        <>
      \end{<key1>}
      <>
      ]],
				{
					key1 = i(1),
					d(2, get_visual),
					i(0),
				},
				{
					repeat_duplicates = true,
				}
			)
		),
		s(
			{ trig = "bigfun", name = "Big function" },
			fmta(
				[[
          \begin{align}
            <>: <> &\longrightarrow <> \\
            <> &\longmapsto <> 
          \end{align}
          <>
        ]],
				{
					i(1, "f"),
					i(2),
					i(3),
					i(4),
					i(5),
					i(0),
				}
			)
		),
	}
end

return M
