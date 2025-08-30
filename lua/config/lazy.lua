-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

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

function _G.gitsigns_head()
	local branch = vim.b.gitsigns_head
	return branch and "[ " .. branch .. " ]" or ""
end

vim.o.statusline = " %{v:lua.gitsigns_head()} %f %= %l,%c  %P "

-- Setup lazy.nvim
require("lazy").setup({
	{ import = "plugins" },

	{
		-- "scottmckendry/cyberdream.nvim",
		-- lazy = false,
		-- priority = 1000,
		-- config = function()
		-- 	vim.cmd("colorscheme cyberdream")
		-- end,
		--
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd("colorscheme kanagawa-wave")
		end,

		-- "RRethy/base16-nvim",
		-- priority = 1000,
		-- config = function()
		-- 	vim.cmd.colorscheme("base16-black-metal-gorgoroth")
		-- 	vim.cmd("highlight TelescopeBorder guifg='#00ffff'")
		-- 	vim.cmd("highlight TelescopeResultsTitle guifg='#ffffff' guibg='none'")
		-- 	vim.cmd("highlight TelescopePromptTitle guifg='#ffffff' guibg='none'")
		-- 	vim.cmd("highlight TelescopePreviewTitle guifg='#ffffff' guibg='none'")
		-- end,
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
