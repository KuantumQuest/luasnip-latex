local M = {}

-- Opciones predeterminadas
local default_opts = {
	use_treesitter = false,
	allow_on_markdown = true,
}

M.setup = function(opts)
	-- Toma más prioridad a la tabla de la derecha 'opts or {}', si opts está vacio o indefinido, será '{}'.
	opts = vim.tbl_deep_extend("force", default_opts, opts or {})

	local augroup = vim.api.nvim_create_augroup("luasnip-latex", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "tex",
		group = augroup,
		once = true,
		callback = function()
			local utils = require("luasnip-latex.utils.utils")
			-- Obtiene la FUNCIÓN para determinar si está en entorno matemático o no.
			local is_math = utils.with_opts(utils.is_math, opts.use_treesitter)
			-- Obtiene la FUNCIÓN para determina si NO está en un entorno matemático. Prácticamente lo contrario a is_math.
			local not_math = utils.with_opts(utils.not_math, opts.use_treesitter)
			M.etup_tex(is_math, not_math) --Se define más adelante.
		end,
	})

	if opts.allow_on_markdown then
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "markdown", "rmd" },
			group = augroup,
			once = true,
			callback = function()
				M.setup_markdown()
			end,
		})
	end
end

local _autosnippets = function(is_math, not_math)
	local autosnippets = {}

	for _, s in ipairs({
		"math_iA",
		"math_fs", -- Function and sub-script
		"math_vec",
		"math_greeks_short", -- Greeks symbols and short commands
	}) do
		vim.list_extend(autosnippets, require(("luasnip-latex.%s"):format(s)).retrieve(is_math))
	end

	for _, s in ipairs({
		"env_latex",
		"env_math",
	}) do
		vim.list_extend(autosnippets, require(("luasnip-latex.%s"):format(s)).retrieve(not_math))
	end

	return autosnippets
end

M.setup_tex = function(is_math, not_math)
	local ls = require("luasnip")
	ls.add_snippets("tex", {
		ls.snippet(
			{
				trig = "pack",
				name = "Package",
			},
			require("luasnip.extras.fmt").fmta("\\usepackage[<>]{<>}", {
				ls.insert_node(1, "Options"),
				ls.insert_node(2, "Package"),
			})
		),
	})

	local math_i = require("luasnip-latex.math_i").retrieve(is_math) --Recibe todos los snippets de 'math_i', pero están en función de is_math, gracias a la función 'pipe' que está en 'utils.lua'

	ls.add_snippets("tex", math_i, { default_priority = 0 }) -- Se añaden los snippets de 'math_i'

	ls.add_snippets("tex", _autosnippets(is_math, not_math), { type = "autosnippets", default_priority = 0 }) --snippet que se autocompletan
end

M.setup_markdown = function()
	local ls = require("luasnip")
	local utils = require("luasnip-latex.utils.utils")
	local pipe = utils.pipe

	local is_math = utils.with_opts(utils.is_math, true)
	local not_math = utils.with_opts(utils.not_math, true)

	local math_i = require("luasnip-latex.math_i").retrieve(is_math)
	ls.add_snippets("markdown", math_i, { default_priority = 0 })

	local autosnippets = _autosnippets(is_math, not_math)
	local trigger_of_snip = function(s)
		return s.trigger
	end

	local to_filter = {}
	for _, str in ipairs({
		"env_latex",
		"env_math",
	}) do
		local t = require(("luasnip-latex.%s"):format(str)).retrieve(not_math)
		vim.list_extend(to_filter, vim.tbl_map(trigger_of_snip, t)) -- Obtiene el "trigger" de cada snippet y lo almacena en "to_filter".
	end
	-- Añadir los entornode markdown, como align:
	local env_markdown = require("luasnip-latex.env_markdown").retrieve(is_math)
	ls.add_snippets("markdown", env_markdown, { default_priority = 0 })

	local filtered = vim.tbl_filter(function(s)
		return not vim.tbl_contains(to_filter, s.trigger)
	end, autosnippets) -- almacena una tabla con los snippets "autosnippets" que no estén en "to_filter", es decir los snippets que no son propios de LaTeX.

	local parse_snippet = ls.extend_decorator.apply(ls.parser.parse_snippet, {
		condition = pipe({ not_math }),
	}) --[[@as function]]
	local s = ls.extend_decorator.apply(ls.snippet, { condition = pipe({ not_math }) })
	local fmta = require("luasnip.extras.fmt").fmta
	local i = ls.insert_node
	local d = ls.dynamic_node
	local sn = ls.snippet_node

	local get_visual = function(_, parent)
		local text = parent.snippet.env.LS_SELECT_DEDENT
		if #text > 0 then
			return sn(nil, { i(1, text) })
		else
			return sn(nil, { i(1) })
		end
	end

	-- tex delimiters
	local env_math_snippets = {
		s({ trig = "mk", name = "Line Math" }, fmta([[$<>$<>]], { d(1, get_visual), i(0) })),
		s(
			{ trig = "nk", name = "Block Math" },
			fmta(
				[[
      $$
      <>
      $$
      ]],
				{
					d(1, get_visual),
				}
			)
		),
	}
	vim.list_extend(filtered, env_math_snippets)

	ls.add_snippets("markdown", filtered, {
		type = "autosnippets",
		default_priority = 0,
	})
end

return M
