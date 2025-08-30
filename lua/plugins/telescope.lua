return {
	"nvim-telescope/telescope.nvim",
	event = "VimEnter",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		{ "nvim-telescope/telescope-ui-select.nvim" },
		{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
	},
	config = function()
		require("telescope").setup({
			defaults = {
				-- Choose a layout strategy (horizontal, vertical, center, or cursor)
				layout_strategy = "vertical",
				-- Adjust layout dimensions and padding
				layout_config = {
					horizontal = {
						-- Places the prompt at the top
						prompt_position = "top",
						-- Adjusts the width of the preview window relative to the overall window
						preview_width = 0.55,
						-- Adjusts the width allocated to the results
						results_width = 0.8,
						-- Sets the overall width and height relative to your Neovim window
						width = 0.9,
						height = 0.85,
						-- Cutoff below which the preview window is disabled
						preview_cutoff = 120,
					},
					vertical = {
						-- In vertical mode, you can also add custom settings if needed
						mirror = false,
						height = 0.6,
					},
					-- If you use the center layout, you could define padding around it here
					center = {
						width = 0.8,
						height = 0.8,
					},
				},
				-- You can also adjust transparency for floating windows here
				-- winblend = 10,
				-- Additional defaults like prompt prefix and selection caret for clarity
				prompt_prefix = "🔍 ",
				selection_caret = "➤ ",
			},
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
				fzf = {},
			},
		})

		-- Enable Telescope extensions if they are installed
		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "ui-select")

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
		vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
		vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
		vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
		vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
		vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
		vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
		vim.keymap.set("n", "<leader>sr", builtin.oldfiles, { desc = "[S]earch [R]ecent Files" })
		vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

		vim.keymap.set("n", "<leader>s.", function()
			builtin.live_grep({
				additional_args = function()
					return { "--hidden", "--glob", "!.git/" }
				end,
				prompt_title = "Live Grep (including hidden files)",
			})
		end, { desc = "[S]earch by Grep (Including Hidden and Dot Files)" })

		vim.keymap.set("n", "<leader>/", function()
			builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
				winblend = 10,
				previewer = false,
			}))
		end, { desc = "[/] Fuzzily search in current buffer" })

		vim.keymap.set("n", "<leader>s/", function()
			builtin.live_grep({
				grep_open_files = true,
				prompt_title = "Live Grep in Open Files",
			})
		end, { desc = "[S]earch [/] in Open Files" })

		-- Shortcut for searching your Neovim configuration files
		vim.keymap.set("n", "<leader>sn", function()
			builtin.find_files({ cwd = vim.fn.stdpath("config") })
		end, { desc = "[S]earch [N]eovim files" })
	end,
}
