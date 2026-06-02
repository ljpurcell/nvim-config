return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	ft = { "markdown" },
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {
		win_options = {
			-- Default rendered conceallevel is 3, which hides concealed text
			-- entirely (no cchar drawn). Our HTML-entity concealing (in the
			-- markdown ftplugin) needs level 2 so the replacement glyph shows.
			conceallevel = { rendered = 2 },
		},
	},
}
