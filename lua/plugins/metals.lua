return {
	"scalameta/nvim-metals",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local metals_config = require("metals").bare_config()

		metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

		metals_config.init_options.statusBarProvider = "on"

		-- Autocmd to attach Metals when opening scala/sbt files
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "scala", "sbt" },
			callback = function()
				require("metals").initialize_or_attach(metals_config)
			end,
		})
	end,
}
