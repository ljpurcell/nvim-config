local start_insert_if_terminal = function()
	local b = vim.api.nvim_get_current_buf()
	local ft = vim.api.nvim_get_option_value("filetype", { buf = b })
	if ft == "terminal" then
		vim.cmd("startinsert")
	end
end

local set = vim.keymap.set

local common_modes = { "n", "i", "v", "t" }

return {

	-- Move around windows
	set(common_modes, "<A-h>", function()
		vim.cmd.wincmd("h")
		start_insert_if_terminal()
	end),

	set(common_modes, "<A-j>", function()
		vim.cmd.wincmd("j")
		start_insert_if_terminal()
	end),

	set(common_modes, "<A-l>", function()
		vim.cmd.wincmd("l")
		start_insert_if_terminal()
	end),

	set({ "n", "i", "v", "t" }, "<A-k>", function()
		vim.cmd.wincmd("k")
		start_insert_if_terminal()
	end),

	set({ "t", "v", "n" }, "<M-,>", "<c-w>5<"),
	set({ "t", "v", "n" }, "<M-.>", "<c-w>5>"),
	set({ "t", "v", "n" }, "<M-=>", "<C-W>+"),
	set({ "t", "v", "n" }, "<M-->", "<C-W>-"),

	set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" }),

	set("n", "<Esc>", "<cmd>nohlsearch<CR>"),

	set("v", "J", ":m '>+1<CR>gv=gv"),
	set("v", "K", ":m '<-2<CR>gv=gv"),
	set({ "n", "v" }, "<leader>y", [["+y]]),
	set("n", "<leader>Y", [["+Y]]),

	set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" }),
	set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" }),
	set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" }),
	set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" }),

	set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>'),
	set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>'),
	set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>'),
	set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>'),
}
