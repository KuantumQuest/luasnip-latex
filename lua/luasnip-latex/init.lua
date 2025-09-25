local M = {}

-- DEFAULT OPTS

local default_opts = {
	use_treesitter = false,
	allow_on_markdown = true,
}

-- PLUGGIN SETUP

M.setup = function(opts)
	opts = vim.tbl_deep_extend("force", default_opts, opts or {}) --unir tablas valor por valor

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
			M.setup_tex(is_math, not_math) --Se define más adelante.
		end,
	})

	if opts.allow_on_markdown then
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "markdown", "rmd", "qmd" },
			group = augroup,
			once = true,
			callback = function()
				M.setup_markdown() --Se define más adelante
			end,
		})
	end
end

-- Load autosnippets of markdown and LaTeX
local _all_autosnippets = function(is_math)
	local autosnippets = {}

  -- In math
	for _, s in ipairs({
		"math_fraction", -- Function and sub-script
		"math_vector",
		"math_symbol", -- Greeks symbols and short commands
    "math_diff",
		"math_base",
    "math_matrix"
	}) do
		vim.list_extend(autosnippets, require(("luasnip-latex.%s"):format(s)).retrieve(is_math))
	end

	return autosnippets
end

-- LATEX SETUP

M.setup_tex = function(is_math, not_math)
	local ls = require("luasnip")
  -- Añadimos los snippets
	local math_base_snippet = require("luasnip-latex.math_base_snippet").retrieve(is_math) --Recibe todos los snippets de 'math_base_snippet', pero están en función de is_math, gracias a la función 'pipe' que está en 'utils.lua'
	ls.add_snippets("tex", math_base_snippet, { default_priority = 0 }) -- Se añaden los snippets de 'math_base_snippet'
  local env_latex= require("luasnip-latex.env_latex").retrieve(not_math)
	ls.add_snippets("tex", env_latex, { default_priority = 0 })

	ls.add_snippets("tex", _all_autosnippets(is_math), { type = "autosnippets", default_priority = 0 }) --snippet que se autocompletan
end

-- MARKDOWN SETUP

M.setup_markdown = function()
	local ls = require("luasnip")
	local utils = require("luasnip-latex.utils.utils")

	local is_math = utils.with_opts(utils.is_math, true)
	local not_math = utils.with_opts(utils.not_math, true)

	local math_base_snippet = require("luasnip-latex.math_base_snippet").retrieve(is_math)
	ls.add_snippets("markdown", math_base_snippet, { default_priority = 0 })
	local env_markdown = require("luasnip-latex.env_markdown").retrieve(not_math)
	ls.add_snippets("markdown", env_markdown, { default_priority = 0 })

	ls.add_snippets("markdown", _all_autosnippets(is_math), { type = "autosnippets", default_priority = 0 })
end

return M
