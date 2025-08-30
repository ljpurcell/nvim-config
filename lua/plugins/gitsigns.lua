return {
	"lewis6991/gitsigns.nvim",
	config = function()
		require("gitsigns").setup({
			-- See `:help gitsigns.txt`
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			signcolumn = true,
			numhl = false,
			linehl = false,
			word_diff = false,
			watch_gitdir = {
				follow_files = true,
			},
			attach_to_untracked = true,
			current_line_blame = false,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 1000,
				ignore_whitespace = false,
			},
			current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
			sign_priority = 6,
			update_debounce = 100,
			max_file_length = 40000,
			preview_config = {
				border = "single",
				style = "minimal",
				relative = "cursor",
				row = 0,
				col = 1,
			},
			yadm = {
				enable = false,
			},

			on_attach = function(bufnr)
				vim.keymap.set("n", "[g", function()
					require("gitsigns").nav_hunk("prev")
				end, { buffer = bufnr, desc = "[Previous] [G]it Hunk" })

				vim.keymap.set("n", "]g", function()
					require("gitsigns").nav_hunk("next")
				end, { buffer = bufnr, desc = "[Next] [G]it Hunk" })

				vim.keymap.set(
					"n",
					"<leader>gr",
					require("gitsigns").reset_hunk,
					{ buffer = bufnr, desc = "[G]it [R]eset" }
				)

				vim.keymap.set(
					"n",
					"<leader>gp",
					require("gitsigns").preview_hunk_inline,
					{ buffer = bufnr, desc = "[G]it [P]review" }
				)

				vim.keymap.set(
					"n",
					"<leader>gb",
					require("gitsigns").blame_line,
					{ buffer = bufnr, desc = "[G]it [R]eset" }
				)
			end,
		})
	end,
}
