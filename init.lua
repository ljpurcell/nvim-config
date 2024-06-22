-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Lazy.nvim setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{ import = "plugins" },
	{
		"rebelot/kanagawa.nvim",
		priority = 1000,
		config = function()
			require("kanagawa").setup({
				colors = {
					theme = {
						all = {
							ui = {
								bg_gutter = "none",
							},
						},
					},
				},
			})

			vim.cmd.colorscheme("kanagawa-dragon")
		end,
	},
}, {
	change_detection = {
		notify = false,
	},
	ui = {
		cmd = "⌘",
		config = "🛠",
		event = "📅",
		ft = "📂",
		init = "⚙",
		keys = "🗝",
		plugin = "🔌",
		runtime = "💻",
		require = "🌙",
		source = "📄",
		start = "🚀",
		task = "📌",
		lazy = "💤 ",
	},
})

-- General settings
vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 10
vim.opt.hlsearch = true

-- Autocommands
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
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
