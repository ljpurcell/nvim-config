return {
	-- Conjure - REPL interaction (essential)
	{
		"Olical/conjure",
		ft = { "clojure", "fennel", "janet" },
		config = function()
			-- Disable diagnostic LSP (we'll use clojure-lsp for this)
			vim.g["conjure#extract#tree_sitter#enabled"] = true
			-- HUD position
			vim.g["conjure#log#hud#width"] = 1.0
			vim.g["conjure#log#hud#height"] = 0.4
			vim.g["conjure#log#hud#anchor"] = "SE"
			vim.g["conjure#log#hud#border"] = "rounded"
		end,
	},

	-- Structural editing (Paredit-style)
	{
		"julienvincent/nvim-paredit",
		ft = { "clojure", "fennel", "scheme" },
		config = function()
			require("nvim-paredit").setup()
		end,
	},
}
