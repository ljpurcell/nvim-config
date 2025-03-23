return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	opts = {
		ensure_installed = { "bash", "c", "html", "lua", "luadoc", "markdown", "templ", "vim", "vimdoc", "python" },
		auto_install = true,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = { "ruby" },
		},
		indent = { enable = true, disable = { "ruby" } },
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
