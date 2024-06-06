local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmta
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	ls.add_snippets("go", {
		s(
			"ie",
			fmt(
				[[
		if <> != nil {
			return <>
		}
		]],
				{
					i(1, "err"),
					i(2, "err"),
				}
			)
		),
	}),
}
