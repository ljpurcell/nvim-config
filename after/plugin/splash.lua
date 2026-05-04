local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

vim.lsp.config("splash", {
	cmd = { "/Users/lyndon/code/splash/splash" },
	root_dir = '/Users/lyndon/code/ihub-recipes',
	filetypes = { "json" },
	root_markers = { ".git" },
	capabilities = capabilities,
	init_options = {
		explodedDir = '/Users/lyndon/code/ihub-recipes-exploded/recipes',
	},
})

vim.lsp.enable("splash")
