local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

vim.lsp.config("splash", {
	cmd = { "/Users/lyndon/code/splash/splash" },
	cmd_env = { SPLASH_LOG_FILE = "/tmp/splash.log" },
	filetypes = { "json" },
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		local hit = vim.fs.find("recipes", { path = fname, upward = true, type = "directory" })[1]
		if hit then on_dir(vim.fs.dirname(hit)) end
	end,
	capabilities = capabilities,
	init_options = {
		explodedDir = '/Users/lyndon/code/ihub-recipes-exploded/recipes',
	},
})

vim.lsp.enable("splash")
