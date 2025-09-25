local ls= require("luasnip")
local fmta = require("luasnip.extras.fmt").fmta
local i = ls.insert_node

local M = {}

function M.retrieve(not_math)
	local utils = require("luasnip-latex.utils.utils")
	local pipe = utils.pipe

	local condition = pipe({ not_math })
	local s = ls.extend_decorator.apply(ls.snippet, {
		condition = condition,
	})
  return {
	s({ trig = "mk", name = "Line Math", snippetType= "autosnippet"}, fmta([[$<>$]], { i(1)})),
	s(
		{ trig = "nk", name = "Block Math", snippetType= "autosnippet"},
		fmta(
			[[
      $$
      <>
      $$
      ]], { i(1) })),
  }
end

return M
