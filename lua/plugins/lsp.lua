return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		{ "j-hui/fidget.nvim", opts = {} },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		-- Create a shared function for LSP keybindings
		local function setup_lsp_keymaps(event)
			local map = function(keys, func, desc)
				vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
			end

			map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
			map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
			map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
			map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols,
				"[W]orkspace [S]ymbols")
			map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
			map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
			map("K", vim.lsp.buf.hover, "Hover Documentation")
			map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

			-- Diagnostic keymaps
			map("<leader>e", vim.diagnostic.open_float, "Show diagnostic [E]rror")
			map("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Go to previous [D]iagnostic")
			map("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Go to next [D]iagnostic")
			map("<leader>q", vim.diagnostic.setloclist, "Open diagnostics list")

			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if client and client.server_capabilities.documentHighlightProvider then
				vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
					buffer = event.buf,
					callback = vim.lsp.buf.document_highlight,
				})

				vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					buffer = event.buf,
					callback = vim.lsp.buf.clear_references,
				})
			end
		end

		-- Make the function globally available so Metals can use it
		_G.setup_lsp_keymaps = setup_lsp_keymaps

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = setup_lsp_keymaps,
		})

		-- LSP capabilities setup
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

		-- Server configurations
		local servers = {
			svelte = {
				filetypes = { "svelte" }
			},
			sourcekit = {
				capabilities = {
					workspace = {
						didChangeWatchedFiles = {
							dynamicRegistration = true,
						},
					},
				},
			},
			gopls = {
				settings = {
					gopls = {
						analyses = {
							unusedparams = true,
						},
						completeUnimported = true,
						gofumpt = true,
						staticcheck = true,
						usePlaceholders = true,
					},
				},
			},
			clojure_lsp = {},
			rust_analyzer = {},
			emmet_ls = {
				filetypes = { "html", "templ" },
			},
			html = {
				filetypes = { "html", "templ" },
			},
			lua_ls = {
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
					},
				},
			},
			pyright = {
				settings = {
					python = {
						checkOnType = true,
					},
				},
			},
			tailwindcss = {},
			templ = {},
			ts_ls = {
				filetypes = { "javascript", "typescript" },
			},
		}

		-- Setup Mason
		require("mason").setup()

		-- Install tools through Mason (excluding sourcekit which isn't available)
		local ensure_installed = vim.tbl_keys(servers or {})
		-- Remove sourcekit from the list as it's not available through Mason
		ensure_installed = vim.tbl_filter(function(name)
			return name ~= "sourcekit"
		end, ensure_installed)

		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		-- Setup LSP servers through Mason
		require("mason-lspconfig").setup({
			handlers = {
				function(server_name)
					local server = servers[server_name] or {}
					server.capabilities = vim.tbl_deep_extend("force", {}, capabilities,
						server.capabilities or {})
					vim.lsp.config(server_name, server)
					vim.lsp.enable(server_name)
				end,
			},
		})

		-- Manual setup for sourcekit (not available through Mason)
		-- Configure and enable sourcekit server
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "swift",
			callback = function(args)
				vim.lsp.start({
					name = "sourcekit",
					cmd = { "sourcekit-lsp" },
					root_dir = vim.fs.root(args.buf, { "Package.swift", ".git" }),
					capabilities = vim.tbl_deep_extend("force", {}, capabilities, {
						workspace = {
							didChangeWatchedFiles = {
								dynamicRegistration = true,
							},
						},
					}),
				})
			end,
		})
	end,
}
