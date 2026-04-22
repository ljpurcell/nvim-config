return {
	"stevearc/conform.nvim",
	lazy = false,
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			mode = "",
			desc = "[F]ormat buffer",
		},
	},
	opts = {
		log_level = vim.log.levels.DEBUG,
		notify_on_error = false,
		format_on_save = function(bufnr)
			local disable_filetypes = { c = true, cpp = true }
			return {
				timeout_ms = 2500,
				lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
			}
		end,
		formatters = {
			biome = {
				command = "biome",
				args = {
					"format",
					"--stdin-file-path",
					"$FILENAME",
					"--format-with-errors",
					"true",
					"--semicolons",
					"always",
					"--trailing-commas",
					"none",
					"--indent-style",
					"space",
					"--indent-width",
					"2",
					"--javascript-formatter-quote-style",
					"single",
				},
				stdin = true,
			},
			prettier = {
				command = "prettier",
				args = { "--stdin-filepath", "$FILENAME" },
				stdin = true,
			},
			stir = {
				command = "/Users/lyndon/go/bin/stir",
				args = { "--context", "$FILENAME" },
				stdin = true,
			},
		},
		formatters_by_ft = {
			astro = { "prettier" },
			typescript = { "prettier" },
			css = { "prettier" },
			svelte = { "prettier" },
			lua = { "stylua" },
			go = { "gofumpt" },
			html = { "prettier" },
			markdown = { "markdownfmt" },
			sql = { "sqruff" },
			javascript = { "biome" },
			json = { "stir" },
			rust = { "rustfmt" },
			templ = { "templ", "superhtml" },
			ocaml = { "ocamlformat" },
			python = { "black" },
			clojure = { "cljfmt" },
			xml = { "xmllint" },
		},
	},
}
