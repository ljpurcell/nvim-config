require("config.lazy")

-- User Commands
vim.api.nvim_create_user_command("Spellcheck", "setlocal spell spelllang=en_au", {})

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
		local clients = vim.lsp.get_clients()
		for _, client in pairs(clients) do
			if client.name == "tailwindcss" then
				vim.cmd("TailwindSort")
				return
			end
		end
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("custom-term-open", {}),
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.scrolloff = 0

		vim.bo.filetype = "terminal"
	end,
})

-- Automatically run it when a markdown file is opened
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.cmd("Spellcheck")
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
