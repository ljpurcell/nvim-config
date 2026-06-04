return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		{
			"L3MON4D3/LuaSnip",
			build = (function()
				if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
					return
				end
				return "make install_jsregexp"
			end)(),
			dependencies = {},
		},
		"saadparwaiz1/cmp_luasnip",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"rafamadriz/friendly-snippets",
	},
	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")
		luasnip.config.setup({})
		require("luasnip.loaders.from_vscode").lazy_load()

		-- Custom snippets
		local fmt = require("luasnip.extras.fmt").fmta
		local s = luasnip.snippet
		local t = luasnip.text_node
		local i = luasnip.insert_node
		local f = luasnip.function_node
		local d = luasnip.dynamic_node
		local sn = luasnip.snippet_node

		-- Kebab-case a title into a URL slug: lowercase, runs of
		-- non-alphanumerics → single "-", trimmed at both ends. Parens wrap the
		-- whole chain so the trailing gsub's count return is dropped — otherwise
		-- kebab returns (slug, count) and the count leaks into the next arg.
		local function kebab(text)
			local slug = (text or "")
			    :lower()
			    :gsub("[^%w]+", "-")
			    :gsub("^%-+", "")
			    :gsub("%-+$", "")
			return slug
		end
		luasnip.add_snippets("go", {
			s(
				"ie",
				fmt(
					[[
		if <> != nil {
			return <>
		}
		]],
					{ i(1, "err"), i(2, "err") }
				)
			),
		})

		-- New blog post frontmatter (Astro `posts` collection). Trigger
		-- "frontmatter" in a markdown buffer; created_at is filled with today's
		-- date at expansion time. slug auto-derives from the title (kebab-cased)
		-- yet stays editable. Defaults: is_published/in_progress = true.
		luasnip.add_snippets("markdown", {
			s(
				"frontmatter",
				fmt(
					[[
---
title: "<>"
description: "<>"
is_published: <>
in_progress: <>
slug: "<>"
created_at: "<>"
---

<>
]],
					{
						i(1, "Title"),
						i(2, "One-line description"),
						i(3, "false"),
						i(4, "true"),
						-- slug pre-fills as kebab(title) and tracks edits to the
						-- title node, but stays editable for a manual override.
						d(5, function(args)
							return sn(nil, { i(1, kebab(args[1][1])) })
						end, { 1 }),
						f(function()
							return os.date("%Y-%m-%d")
						end),
						i(0),
					}
				)
			),
		})

		cmp.setup({
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			completion = { completeopt = "menu,menuone,noinsert" },

			mapping = cmp.mapping.preset.insert({
				-- Select the [n]ext item
				["<C-n>"] = cmp.mapping.select_next_item(),
				-- Select the [p]revious item
				["<C-p>"] = cmp.mapping.select_prev_item(),

				-- Scroll the documentation window [b]ack / [f]orward
				["<C-->"] = cmp.mapping.scroll_docs(-4),
				["<C-=>"] = cmp.mapping.scroll_docs(4),

				-- Accept ([y]es) the completion.
				["<C-y>"] = cmp.mapping.confirm({ select = true }),

				-- Manually trigger a completion from nvim-cmp.
				--  Generally you don't need this, because nvim-cmp will display
				--  completions whenever it has completion options available.
				["<C-Space>"] = cmp.mapping.complete({}),

				["<C-f>"] = cmp.mapping(function()
					if luasnip.expand_or_locally_jumpable() then
						luasnip.expand_or_jump()
					end
				end, { "i", "s" }),
				["<C-b>"] = cmp.mapping(function()
					if luasnip.locally_jumpable(-1) then
						luasnip.jump(-1)
					end
				end, { "i", "s" }),
			}),
			sources = {
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
				{ name = "buffer" },
			},

			performance = {
				max_view_entries = 10,
				fetching_timeout = 5,
			},
		})
	end,
}
