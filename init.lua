require("config.lazy")

-- Autocommands
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.css", "*.html", "*.templ" },
	callback = function()
		vim.cmd("TailwindSort")
	end,
})

-- Terminal
vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("custom-term-open", {}),
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.scrolloff = 0

		vim.bo.filetype = "terminal"
	end,
})

-- Toggle terminal on the RHS
-- TODO: Return cursor to previous window and position
vim.keymap.set({ "n", "i", "v", "t" }, "<C-t>", function()
	local windows = vim.api.nvim_list_wins()

	for _, w in pairs(windows) do
		local buff = vim.api.nvim_win_get_buf(w)
		local ft = vim.api.nvim_get_option_value("filetype", { buf = buff })
		if ft == "terminal" then
			vim.api.nvim_win_close(w, false)
			return
		end
	end

	vim.cmd.new()
	vim.cmd.wincmd("L")
	vim.api.nvim_win_set_width(0, 50)
	vim.cmd.term()
	vim.cmd("startinsert")
end)
