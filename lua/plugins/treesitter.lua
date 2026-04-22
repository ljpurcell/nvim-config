return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local langs = { "svelte", "html", "javascript", "typescript", "css", "lua", "go", "python" }

		require('nvim-treesitter').install(langs)

		vim.api.nvim_create_autocmd("FileType", {
			pattern = langs,
			callback = function()
				vim.treesitter.start()

				vim.wo.foldmethod = "expr"
				vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.opt.foldlevel = 99 -- keeps open by default
			end,
		})
	end,
}
