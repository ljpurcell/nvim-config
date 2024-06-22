return {
	-- Move around windows
	vim.keymap.set({ "n", "i", "v", "t" }, "<A-h>", function()
		vim.cmd.wincmd("h")
	end),

	vim.keymap.set({ "n", "i", "v", "t" }, "<A-j>", function()
		vim.cmd.wincmd("j")
	end),

	vim.keymap.set({ "n", "i", "v", "t" }, "<A-l>", function()
		vim.cmd.wincmd("l")
	end),

	vim.keymap.set({ "n", "i", "v", "t" }, "<A-k>", function()
		vim.cmd.wincmd("k")
	end),

	vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" }),

	vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>"),

	vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv"),
	vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv"),
	vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]]),
	vim.keymap.set("n", "<leader>Y", [["+Y]]),

	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" }),
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" }),
	vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" }),
	vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" }),

	vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>'),
	vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>'),
	vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>'),
	vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>'),
}
