return {
	"scalameta/nvim-metals",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	ft = { "scala", "sbt", "java" },
	opts = function()
		local metals_config = require("metals").bare_config()

		-- Use the same capabilities as your main LSP config
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
		metals_config.capabilities = capabilities

		-- Use the same telescope-based LSP keymaps from your main LSP config
		metals_config.on_attach = function(client, bufnr)
			-- Create a mock event object that matches what your setup_lsp_keymaps expects
			local mock_event = {
				buf = bufnr,
				data = { client_id = client.id },
			}

			-- Call the global function you defined in your LSP config
			if _G.setup_lsp_keymaps then
				_G.setup_lsp_keymaps(mock_event)
				print("LSP keymaps setup complete for Metals")
			else
				print("Warning: _G.setup_lsp_keymaps not found")
			end

			-- Ensure telescope keymaps are available (in case of loading order issues)
			local telescope_ok, builtin = pcall(require, "telescope.builtin")
			if telescope_ok then
				-- Set up the same telescope keymaps from your telescope config, but with Scala-friendly defaults
				vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp", buffer = bufnr })
				vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps", buffer = bufnr })

				-- Override find_files to be selective for Scala projects
				vim.keymap.set("n", "<leader>sf", function()
					builtin.find_files({
						no_ignore = true,
						hidden = true,
						file_ignore_patterns = {
							"target/",
							".bloop/",
							".metals/",
							".bsp/",
							"project/target/",
							"project/project/",
							"%.class$",
							"%.jar$",
							"%.log$",
							"node_modules/",
							".git/",
						},
					})
				end, { desc = "[S]earch [F]iles", buffer = bufnr })

				vim.keymap.set(
					"n",
					"<leader>ss",
					builtin.builtin,
					{ desc = "[S]earch [S]elect Telescope", buffer = bufnr }
				)
				vim.keymap.set(
					"n",
					"<leader>sw",
					builtin.grep_string,
					{ desc = "[S]earch current [W]ord", buffer = bufnr }
				)

				-- Override live_grep to be selective for Scala projects
				vim.keymap.set("n", "<leader>sg", function()
					builtin.live_grep({
						additional_args = {
							"--no-ignore",
							"--hidden",
							"--glob",
							"!target/",
							"--glob",
							"!.bloop/",
							"--glob",
							"!.metals/",
							"--glob",
							"!.bsp/",
							"--glob",
							"!project/target/",
							"--glob",
							"!project/project/",
							"--glob",
							"!*.class",
							"--glob",
							"!*.jar",
							"--glob",
							"!*.log",
							"--glob",
							"!node_modules/",
							"--glob",
							"!.git/",
						},
					})
				end, { desc = "[S]earch by [G]rep", buffer = bufnr })

				vim.keymap.set(
					"n",
					"<leader>sd",
					builtin.diagnostics,
					{ desc = "[S]earch [D]iagnostics", buffer = bufnr }
				)
				vim.keymap.set(
					"n",
					"<leader>sr",
					builtin.oldfiles,
					{ desc = "[S]earch [R]ecent Files", buffer = bufnr }
				)
				vim.keymap.set(
					"n",
					"<leader><leader>",
					builtin.buffers,
					{ desc = "[ ] Find existing buffers", buffer = bufnr }
				)

				vim.keymap.set("n", "<leader>s.", function()
					builtin.live_grep({
						additional_args = function()
							return {
								"--hidden",
								"--no-ignore",
								"--glob",
								"!target/",
								"--glob",
								"!.bloop/",
								"--glob",
								"!.metals/",
								"--glob",
								"!.bsp/",
								"--glob",
								"!project/target/",
								"--glob",
								"!project/project/",
								"--glob",
								"!*.class",
								"--glob",
								"!*.jar",
								"--glob",
								"!*.log",
								"--glob",
								"!node_modules/",
								"--glob",
								"!.git/",
							}
						end,
						prompt_title = "Live Grep (including hidden files)",
					})
				end, { desc = "[S]earch by Grep (Including Hidden and Dot Files)", buffer = bufnr })

				vim.keymap.set("n", "<leader>/", function()
					builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
						winblend = 10,
						previewer = false,
					}))
				end, { desc = "[/] Fuzzily search in current buffer", buffer = bufnr })

				vim.keymap.set("n", "<leader>s/", function()
					builtin.live_grep({
						grep_open_files = true,
						prompt_title = "Live Grep in Open Files",
					})
				end, { desc = "[S]earch [/] in Open Files", buffer = bufnr })

				vim.keymap.set("n", "<leader>sn", function()
					builtin.find_files({ cwd = vim.fn.stdpath("config") })
				end, { desc = "[S]earch [N]eovim files", buffer = bufnr })
			else
				print("Warning: telescope.builtin not available")
			end
		end

		return metals_config
	end,
	config = function(self, metals_config)
		local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			pattern = self.ft,
			callback = function()
				require("metals").initialize_or_attach(metals_config)
			end,
			group = nvim_metals_group,
		})
	end,
}
