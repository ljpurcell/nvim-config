return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"bash",
			"c",
			"html",
			"json",
			"javascript",
			"lua",
			"luadoc",
			"markdown",
			"markdown_inline",
			"regex",
			"rust",
			"templ",
			"vim",
			"vimdoc",
			"python",
			"scala",
		},
		auto_install = true,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
		},
		indent = { enable = true, disable = { "ruby" } },
		incremental_selection = {
			enable = true,
		},
		inject = {
			enable = true,
		},
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)

		-- Filetype extensions
		vim.filetype.add({
			extension = {
				templ = "templ",
			},
		})
	end,
}
