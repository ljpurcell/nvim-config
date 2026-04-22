require("config.lazy")

-- User Commands
vim.api.nvim_create_user_command("Spellcheck", "setlocal spell spelllang=en_au", {})

-- Autocommands

-- Custom syntax highlighting for JavaScript in JSON
vim.api.nvim_create_autocmd("FileType", {
	pattern = "json",
	callback = function()
		vim.cmd([[
      " Load JavaScript syntax
      syntax include @JavaScript syntax/javascript.vim

      " Match multiline JavaScript in jsFunc values
      syntax region jsonJavaScriptFunc start=/"jsFunc":\s*"/ end=/"/ contains=@JavaScript skipnl skipwhite

      " Match multiline JavaScript in keyFunc values
      syntax region jsonJavaScriptKey start=/"keyFunc":\s*"/ end=/"/ contains=@JavaScript skipnl skipwhite

      " Match valueDeserializer
      syntax region jsonJavaScriptDeser start=/"valueDeserializer":\s*"/ end=/"/ contains=@JavaScript skipnl skipwhite
    ]])
	end,
})

vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
	callback = function()
		vim.cmd("redrawstatus")
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
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

-- Print the visual selection in a file specific way
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python" },
	callback = function()
		local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
		vim.fn.setreg("p", "yoprint('" .. esc .. "pa:', " .. esc .. "pa)" .. esc)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "javascript" },
	callback = function()
		local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
		vim.fn.setreg("p", "yoconsole.log('" .. esc .. "pa:', " .. esc .. "pa)" .. esc)
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

vim.lsp.config["ocamllsp"] = {
	cmd = { "ocamllsp" },
	filetypes = {
		"ocaml",
		"ocaml.interface",
		"ocaml.menhir",
		"ocaml.ocamllex",
		"dune",
		"reason",
	},
	root_markers = {
		{ "dune-project", "dune-workspace" },
		{ "*.opam",       "esy.json",      "package.json" },
		".git",
	},
	settings = {},
}

vim.lsp.enable("ocamllsp")
