local M = {}

-- local s = ls.snippet
-- local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
-- local t = ls.text_node
-- local i = ls.insert_node
-- local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
-- local events = require("luasnip.util.events")
-- local r = require("luasnip.extras").rep
-- local fmt = require("luasnip.extras.fmt").fmt
--
-- local fmta = require("luasnip.extras.fmt").fmta

-- Es como el pipe de Linux para extender comandos!
M.pipe = function(fns) --- Función que toma como argumento una tabla de funciones.
	--- Retorna una función que recibe todos los argumentos de la función padre.
	--- Es necesario por que es posible que las funciones sean puestas en `condition` de ls.snippet(), y conditions por defecto otorga argumentos
	return function(...)
		for _, fn in ipairs(fns) do
			if not fn(...) then -- La función 'fn' vuelve a tomar todos los argumentos.
				return false
			end
		end

		return true
	end
end

M.no_backslash = function(line_to_cursor, matched_trigger) --Tiene dos parámetros de `conditions` de opts de `ls.snippet()`.
	return not line_to_cursor:find("\\%a+$", -#line_to_cursor)
end

local ts_utils = require("luasnip-latex.utils.ts_utils")
-- Si la función recibe que el treesitter es falso, esta función retornara un booleano indicando si está dentro de una zona matemático en un archivo .tex
M.is_math = function(treesitter)
	if treesitter then
		return ts_utils.in_mathzone()
	end

	return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

M.not_math = function(treesitter)
	if treesitter then
		return ts_utils.in_text(true)
	end

	return not M.is_math()
end

M.comment = function()
	return vim.fn["vimtex#syntax#in_comment"]() == 1
end

M.env = function(name)
	local x, y = unpack(vim.fn["vimtex#env#is_inside"](name))
	return x ~= "0" and y ~= "0"
end

M.with_priority = function(snip, priority)
	snip.priority = priority
	return snip
end

--`with_opts` envuelve una función dada `fn` con opciones específicas `opts`.
--Esto crea una nueva función que, cuando se llama, ejecuta `fn` pasándole `opts`.
--@param fn function: La función a envolver.
--@param opts table: Las opciones que se pasarán a `fn`.
--@return function: Una nueva función que al llamarse invoca `fn` con `opts`.
M.with_opts = function(fn, opts)
	return function()
		return fn(opts)
	end
end

return M
