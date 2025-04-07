local start_insert_if_terminal = function()
	local b = vim.api.nvim_get_current_buf()
	local ft = vim.api.nvim_get_option_value("filetype", { buf = b })
	if ft == "terminal" then
		vim.cmd("startinsert")
	end
end

local set = vim.keymap.set

local non_insert_modes = { "n", "v", "t" }

return {

	-- Move around windows
	set(non_insert_modes, "<leader>wh", function()
		vim.cmd.wincmd("h")
		start_insert_if_terminal()
	end),

	set(non_insert_modes, "<leader>wj", function()
		vim.cmd.wincmd("j")
		start_insert_if_terminal()
	end),

	set(non_insert_modes, "<leader>wl", function()
		vim.cmd.wincmd("l")
		start_insert_if_terminal()
	end),

	set(non_insert_modes, "<leader>wk", function()
		vim.cmd.wincmd("k")
		start_insert_if_terminal()
	end),

	-- Resize windows
	set(non_insert_modes, "<M-,>", "<c-w>5<"),
	set(non_insert_modes, "<M-.>", "<c-w>5>"),
	set(non_insert_modes, "<M-=>", "<C-W>+"),
	set(non_insert_modes, "<M-->", "<C-W>-"),

	set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" }),

	set("n", "<Esc>", "<cmd>nohlsearch<CR>"),

	-- Move selected text
	set("v", "J", ":m '>+1<CR>gv=gv"),
	set("v", "K", ":m '<-2<CR>gv=gv"),

	-- Yank to system clipboard
	set({ "n", "v" }, "<leader>y", [["+y]]),
	set("n", "<leader>Y", [["+Y]]),

	-- Diagnostics
	set("n", "[d", function()
		vim.diagnostic.jump({ count = -1, float = true })
	end, { desc = "Go to previous [D]iagnostic message" }),

	set("n", "]d", function()
		vim.diagnostic.jump({ count = 1, float = true })
	end, { desc = "Go to next [D]iagnostic message" }),

	set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" }),

	set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>'),
	set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>'),
	set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>'),
	set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>'),
}
