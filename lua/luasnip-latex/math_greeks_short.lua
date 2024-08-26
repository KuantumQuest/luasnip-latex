local ls = require("luasnip")
local s = ls.snippet
local f = ls.function_node

-- Snippets de tipo literal, como "sin"-> "\sin"

local M = {}

M.decorator = {}

local prefix_sgreek = "æ"
local trigineitor = function(prefix, pattern)
	return string.format("%s(%s)", prefix, pattern)
end

local unique_node = function(latex)
	return f(function(_, _)
		return ("\\%s"):format(latex)
	end, {})
end

local build_snippet = function(trig_f, node_f, content, priority, name)
	return s({
		name = name and name(content[3]) or content[3], --Si name está presente, entonces se llama a la función name con pattern como argumento; de lo contrario, se utiliza el valor de pattern directamente.
		trig = trig_f(content[1], content[2]),
		priority = priority,
	}, vim.deepcopy(node_f(content[3])))
end

local build_with_priority = function(trig_f, node_f, priority, name)
	return function(content)
		return build_snippet(trig_f, node_f, content, priority, name)
	end
end

local vargreek_snippets = function()
	local tbl = {
		{ prefix_sgreek, "E", "varepsilon" },
		{ prefix_sgreek, "P", "varphi" },
		{ prefix_sgreek, "R", "varrho" },
		{ prefix_sgreek, "T", "vartheta" },
	}

	local build = build_with_priority(trigineitor, unique_node, 10)
	return vim.tbl_map(build, tbl)
end

local greek_lower_snippets = function()
	local tbl = {
		{ prefix_sgreek, "ep", "epsilon" },
		{ prefix_sgreek, "de", "delta" },
		{ prefix_sgreek, "ph", "phi" },
		{ prefix_sgreek, "th", "theta" },
		{ prefix_sgreek, "al", "alpha" },
		{ prefix_sgreek, "ga", "gamma" },
		{ prefix_sgreek, "ze", "zeta" },
		{ prefix_sgreek, "et", "eta" },
		{ prefix_sgreek, "la", "lambda" },
		{ prefix_sgreek, "mu", "mu" },
		{ prefix_sgreek, "xi", "xi" },
		{ prefix_sgreek, "pi", "pi" },
		{ prefix_sgreek, "rh", "rho" },
		{ prefix_sgreek, "ta", "tau" },
		{ prefix_sgreek, "om", "omega" },
		{ prefix_sgreek, "ch", "chi" },
	}
	local build = build_with_priority(trigineitor, unique_node, 10)
	return vim.tbl_map(build, tbl)
end

local greek_upper_snippets = function()
	local tbl = {
		{ prefix_sgreek, "De", "Delta" },
		{ prefix_sgreek, "Ph", "Phi" },
		{ prefix_sgreek, "Ga", "Gamma" },
		{ prefix_sgreek, "Pi", "Pi" },
		{ prefix_sgreek, "Om", "Omega" },
	}
	local build = build_with_priority(trigineitor, unique_node, 10)
	return vim.tbl_map(build, tbl)
end

local short_commands = function()
	local tbl = {
		{ "", "ln", "ln " },
		{ "", "log", "log " },
		{ "", "exp", "exp " },
		{ "", "perp", "perp " },
		{ "", "int", "int " },
	}
	local build = build_with_priority(trigineitor, unique_node, 10)
	return vim.tbl_map(build, tbl)
end

local snippets = {}

function M.retrieve(is_math)
	local utils = require("luasnip-latex.utils.utils")
	local pipe = utils.pipe
	--local no_backslash = utils.no_backslash
	M.decorator = {
		wordTrig = false,
		regTrig = true,
		condition = pipe({ is_math }),
	}
	s = ls.extend_decorator.apply(ls.snippet, M.decorator)
	vim.list_extend(snippets, vargreek_snippets())
	vim.list_extend(snippets, greek_lower_snippets())
	vim.list_extend(snippets, greek_upper_snippets())
	vim.list_extend(snippets, short_commands())
	return snippets
end

return M
