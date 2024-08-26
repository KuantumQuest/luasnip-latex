local ls = require("luasnip")
local i = ls.insert_node
local sn = ls.snippet_node
local d = ls.dynamic_node

local fmta = require("luasnip.extras.fmt").fmta

local utils = require("luasnip-latex.utils.utils")
local pipe = utils.pipe

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
	local s = ls.extend_decorator.apply(ls.snippet, { condition = pipe({ not_math }) })

	return {
		s({ trig = "mk", name = "Line Math" }, fmta([[$ <> $<>]], { d(1, get_visual), i(0) })),
		s(
			{ trig = "nk", name = "Block Math" },
			fmta(
				[[
      \[
        <>
      \]
      <>
      ]],
				{ d(1, get_visual), i(0) }
			)
		),
	}
end

return M
