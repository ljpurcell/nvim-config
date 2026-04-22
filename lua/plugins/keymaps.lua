local start_insert_if_terminal = function()
	local b = vim.api.nvim_get_current_buf()
	local ft = vim.api.nvim_get_option_value("filetype", { buf = b })
	if ft == "terminal" then
		vim.cmd("startinsert")
	end
end

local set = vim.keymap.set

local non_insert_modes = { "n", "v", "t" }

-- ~/.config/nvim/lua/config/clojure-keymaps.lua

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "clojure" },
	callback = function()
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = true, desc = desc, silent = true })
		end

		-- Set localleader to comma for Clojure files
		vim.g.maplocalleader = ","

		-- ============ EVALUATION ============
		-- Most used commands - keep defaults, they're excellent
		map("n", "<localleader>ee", "<cmd>ConjureEval<CR>", "Eval form under cursor")
		map("n", "<localleader>er", "<cmd>ConjureEvalRoot<CR>", "Eval root/top-level form")
		map("n", "<localleader>eb", "<cmd>ConjureEvalBuf<CR>", "Eval entire buffer")
		map("n", "<localleader>e!", "<cmd>ConjureEvalReplaceForm<CR>", "Eval and replace form")
		map("v", "<localleader>e", "<cmd>ConjureEvalVisual<CR>", "Eval visual selection")

		-- Eval and comment (useful for side effects)
		map("n", "<localleader>ec", "<cmd>ConjureEvalComment<CR>", "Eval and comment result")
		map("n", "<localleader>emc", "<cmd>ConjureEvalMarkedForm<CR>", "Eval marked form")

		-- ============ REPL LOG ============
		map("n", "<localleader>lt", "<cmd>ConjureLogToggle<CR>", "Toggle log")
		map("n", "<localleader>ls", "<cmd>ConjureLogSplit<CR>", "Open log in split")
		map("n", "<localleader>lv", "<cmd>ConjureLogVSplit<CR>", "Open log in vsplit")
		map("n", "<localleader>lr", "<cmd>ConjureLogResetSoft<CR>", "Soft reset log")
		map("n", "<localleader>lR", "<cmd>ConjureLogResetHard<CR>", "Hard reset log")
		map("n", "<localleader>lq", "<cmd>ConjureLogCloseVisible<CR>", "Close visible log")

		-- ============ DOCUMENTATION ============
		map("n", "K", "<cmd>ConjureDocWord<CR>", "Show doc for word under cursor")
		map("n", "<localleader>k", "<cmd>ConjureDocWord<CR>", "Show documentation")

		-- ============ DEFINITION & REFERENCES (LSP) ============
		map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", "Go to definition")
		map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", "Go to declaration")
		map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", "Show references")
		map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", "Go to implementation")
		map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename symbol")

		-- ============ TESTING (if using clojure.test) ============
		map("n", "<localleader>tn", "<cmd>ConjureRunCurrentTest<CR>", "Run test under cursor")
		map("n", "<localleader>ta", "<cmd>ConjureRunAllTests<CR>", "Run all tests")
		map("n", "<localleader>tf", "<cmd>ConjureRunCurrentNSTests<CR>", "Run namespace tests")

		-- ============ CONNECT TO REPL ============
		map("n", "<localleader>cf", "<cmd>ConjureConnect<CR>", "Connect to REPL")
		map("n", "<localleader>cq", "<cmd>ConjureConnectionStop<CR>", "Disconnect from REPL")

		-- ============ OPTIONAL: PAREDIT-STYLE ============
		-- Uncomment if you want custom paredit bindings
		-- These work with nvim-paredit
		-- local paredit = require("nvim-paredit")
		-- map("n", "<localleader>>", paredit.slurp_forwards, "Slurp forward")
		-- map("n", "<localleader><", paredit.barf_forwards, "Barf forward")
		-- map("n", "<localleader>I", paredit.raise_form, "Raise form")
		-- map("n", "<localleader>O", paredit.raise_element, "Raise element")
		-- map("n", "<localleader>S", paredit.splice_sexp, "Splice sexp")
		-- map("n", "<localleader>W", paredit.wrap_element_round, "Wrap element in ()")
		-- map("v", "<localleader>(", paredit.wrap_round, "Wrap selection in ()")
		-- map("v", "<localleader>[", paredit.wrap_square, "Wrap selection in []")
		-- map("v", "<localleader>{", paredit.wrap_curly, "Wrap selection in {}")
	end,
})

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
