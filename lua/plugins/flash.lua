return {
	"folke/flash.nvim",
	event = "VeryLazy",
	---@type Flash.Config
	opts = {
		-- Base label pool; `label.uppercase = true` (default) auto-appends the
		-- uppercase letters, and the trailing digits add ~10 more keys.
		-- Expands addressable matches to ~62 for dense, text-heavy buffers.
		labels = "asdfghjklqwertyuiopzxcvbnm1234567890",
		search = {
			-- Stop reserving labels for pattern continuation after 1 char,
			-- so single common letters (e.g. 'a', 't') always get jump labels.
			-- Tradeoff: no multi-char narrowing in flash (use regular search for that).
			max_length = 1,
		},
	},
	-- stylua: ignore
	keys = {
		{ "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
		{ "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
		{ "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
		{ "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
		{ "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
	},
}
