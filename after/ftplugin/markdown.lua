if vim.b.markdown_ftplugin_loaded then
	return
end
vim.b.markdown_ftplugin_loaded = true

local unpack = unpack or table.unpack

-- ---------------------------------------------------------------------------
-- Prose-friendly soft wrapping
-- ---------------------------------------------------------------------------
vim.opt_local.wrap = true        -- wrap long lines instead of running off-screen
vim.opt_local.linebreak = true   -- break at word boundaries, not mid-word
vim.opt_local.breakindent = true -- keep wrapped lines visually indented

-- Move by visual line, but keep counts working (e.g. 5j still jumps 5 lines).
local function visual_motion(key)
	return function()
		return vim.v.count == 0 and ("g" .. key) or key
	end
end
vim.keymap.set({ "n", "x" }, "j", visual_motion("j"), { buffer = true, expr = true, desc = "Down by visual line" })
vim.keymap.set({ "n", "x" }, "k", visual_motion("k"), { buffer = true, expr = true, desc = "Up by visual line" })

-- ---------------------------------------------------------------------------
-- Spell checking
-- ---------------------------------------------------------------------------
vim.opt_local.spell = true
vim.opt_local.spelllang = "en_au"

-- <leader>ca: when the word under the cursor is misspelled, offer spelling
-- suggestions (through vim.ui.select -> telescope); otherwise fall back to the
-- LSP code action. Re-asserted on LspAttach so marksman's mapping can't shadow it.
local function spell_suggest_or_code_action()
	local word = vim.fn.expand("<cword>")
	if word == "" or vim.fn.spellbadword(word)[1] == "" then
		vim.lsp.buf.code_action()
		return
	end

	-- Suggestions first (z= and spellsuggest share ordering), then dictionary
	-- actions: zg adds the word permanently, zG ignores it for this session.
	local items = {}
	for i, s in ipairs(vim.fn.spellsuggest(word)) do
		items[#items + 1] = { label = s, run = function() vim.cmd("normal! " .. i .. "z=") end }
	end
	items[#items + 1] = { label = ("＋ Add %q to dictionary"):format(word), run = function() vim.cmd("normal! zg") end }
	items[#items + 1] = { label = ("＋ Ignore %q this session"):format(word), run = function() vim.cmd("normal! zG") end }

	vim.ui.select(items, {
		prompt = ("Spelling: %q"):format(word),
		format_item = function(item) return item.label end,
	}, function(choice)
		if choice then
			choice.run()
		end
	end)
end

local function map_code_action()
	vim.keymap.set("n", "<leader>ca", spell_suggest_or_code_action, {
		buffer = 0,
		desc = "[C]ode [A]ction / spelling fix",
	})
end

map_code_action()
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("markdown_spell_code_action", { clear = false }),
	buffer = 0,
	desc = "Keep <leader>ca as spelling/code-action in markdown",
	callback = map_code_action,
})

-- ---------------------------------------------------------------------------
-- Footnotes
-- ---------------------------------------------------------------------------
vim.keymap.set("n", "<leader>fn", function()
	local buf = 0
	-- nvim_win_get_cursor -> { row (1-based), col (0-based byte index) }
	local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	-- The marker goes at the end of the word under the cursor: just before the
	-- next space, so it lands after any trailing punctuation. No space ahead
	-- means end of line.
	local space = lines[lnum]:find("%s", col + 1)
	local at = space and (space - 1) or #lines[lnum]

	-- New footnote number: one past the highest reference at or before the
	-- marker, so footnotes stay numbered in reading order.
	local new_num = 0
	for i = 1, lnum do
		local scan = (i == lnum) and lines[i]:sub(1, at) or lines[i]
		for n in scan:gmatch("%[%^(%d+)%]") do
			new_num = math.max(new_num, tonumber(n))
		end
	end
	new_num = new_num + 1

	-- Shift every existing footnote numbered >= new_num up by one -- both inline
	-- references "[^k]" and definitions "[^k]:" (the pattern matches the "[^k]"
	-- prefix of each). Done before inserting so the new marker keeps new_num.
	for i = 1, #lines do
		lines[i] = (lines[i]:gsub("%[%^(%d+)%]", function(n)
			n = tonumber(n)
			return n >= new_num and ("[^" .. n + 1 .. "]") or nil
		end))
	end

	-- Drop the inline reference in at the end of the current word (the prefix up
	-- to `at` is untouched by the renumber, since those references are < new_num).
	local marker = "[^" .. new_num .. "]"
	local line = lines[lnum]
	lines[lnum] = line:sub(1, at) .. marker .. line:sub(at + 1)

	-- Place the definition with the run of "[^k]:" definitions that follows the
	-- current paragraph, keeping them in ascending order: it goes after the last
	-- existing definition numbered below new_num (so a following definition
	-- paragraph lower than n stays above it). If none qualifies it starts its
	-- own block right after the paragraph (markdown needs it blank-separated).
	local defline = marker .. ": "
	local function defnum(s)
		local d = s and s:match("^%[%^(%d+)%]:")
		return d and tonumber(d) or nil
	end

	-- pe = last non-blank line of the paragraph the cursor sits in.
	local pe = lnum
	while pe < #lines and lines[pe + 1] ~= "" do
		pe = pe + 1
	end

	-- Walk the following definitions -- one contiguous block or several
	-- blank-separated paragraphs -- tracking the last one numbered below new_num.
	local anchor = pe
	local i = pe + 1
	while i <= #lines do
		local n = defnum(lines[i])
		if n then
			if n < new_num then
				anchor = i
			end
			i = i + 1
		elseif lines[i] == "" and defnum(lines[i + 1]) then
			i = i + 1 -- blank between two definition paragraphs: keep scanning
		else
			break -- prose or a wider gap: the definitions have ended
		end
	end

	local def_lnum
	if anchor > pe then
		-- Blank-separate the new definition from the one above it (and from a
		-- contiguous higher-numbered definition below, if there is one).
		table.insert(lines, anchor + 1, "")
		table.insert(lines, anchor + 2, defline)
		def_lnum = anchor + 2
		if defnum(lines[anchor + 3]) then
			table.insert(lines, anchor + 3, "")
		end
	elseif pe < #lines then
		-- New lowest definition (or none follow): start the block after the
		-- paragraph, blank-separating it from whatever comes next.
		table.insert(lines, pe + 2, defline)
		def_lnum = pe + 2
		local after = lines[pe + 3]
		if after ~= nil and after ~= "" then
			table.insert(lines, pe + 3, "")
		end
	else
		-- Paragraph runs to end of file: add a blank separator then the def.
		lines[#lines + 1] = ""
		lines[#lines + 1] = defline
		def_lnum = #lines
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- Jump to the new definition, ready to type the note.
	vim.api.nvim_win_set_cursor(0, { def_lnum, 0 })
	vim.cmd("startinsert!")
end, { buffer = true, desc = "Insert markdown footnote" })

-- ---------------------------------------------------------------------------
-- Bold / italic
-- ---------------------------------------------------------------------------
-- Wrap the visual selection (x) or the word under the cursor (n).
vim.keymap.set("x", "<leader>b", 'c**<C-r>"**<Esc>', { buffer = true, desc = "Markdown bold" })
vim.keymap.set("x", "<leader>i", 'c*<C-r>"*<Esc>', { buffer = true, desc = "Markdown italic" })
vim.keymap.set("n", "<leader>b", 'viwc**<C-r>"**<Esc>', { buffer = true, desc = "Markdown bold word" })
vim.keymap.set("n", "<leader>i", 'viwc*<C-r>"*<Esc>', { buffer = true, desc = "Markdown italic word" })

-- ---------------------------------------------------------------------------
-- Render common HTML entities in-buffer (conceal the source, show the glyph).
-- Extmark-based so it coexists with treesitter / render-markdown. The entity
-- stays raw on the cursor's line (concealcursor = "") so it's easy to edit.
-- ---------------------------------------------------------------------------
vim.opt_local.conceallevel = 2
vim.opt_local.concealcursor = ""

local entities = {
	["&mdash;"] = "—",
	["&ndash;"] = "–",
	["&hellip;"] = "…",
	["&amp;"] = "&",
	["&copy;"] = "©",
	["&reg;"] = "®",
	["&trade;"] = "™",
	["&deg;"] = "°",
	["&times;"] = "×",
	["&lt;"] = "<",
	["&gt;"] = ">",
	["&quot;"] = '"',
}

local entity_ns = vim.api.nvim_create_namespace("markdown_entities")

local function render_entities()
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_clear_namespace(buf, entity_ns, 0, -1)
	for lnum, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
		for ent, glyph in pairs(entities) do
			local from = 1
			while true do
				local s, e = line:find(ent, from, true)
				if not s then
					break
				end
				vim.api.nvim_buf_set_extmark(buf, entity_ns, lnum - 1, s - 1, {
					end_row = lnum - 1,
					end_col = e,
					conceal = glyph,
					hl_group = "Normal", -- without this the cchar uses dim Conceal hl
				})
				from = e + 1
			end
		end
	end
end

render_entities()
vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
	group = vim.api.nvim_create_augroup("markdown_entities_refresh", { clear = false }),
	buffer = 0,
	desc = "Refresh HTML entity concealing",
	callback = render_entities,
})

-- ---------------------------------------------------------------------------
-- Turn "--" into "&mdash;", while leaving "---" alone (horizontal rule /
-- frontmatter fence).
--
-- A plain :iabbrev can't do this: it fires on the next char without looking
-- ahead, and typing the third "-" of "---" would itself expand "--".
-- The only moment "--" and "---" are distinguishable is when the char *after*
-- "--" is typed -- so conversion happens one keystroke late: type the char
-- following "--" and, if it isn't another "-", the dashes become "&mdash;".
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd("InsertCharPre", {
	group = vim.api.nvim_create_augroup("markdown_mdash", { clear = false }),
	buffer = 0,
	desc = "Convert -- to &mdash; (but not ---)",
	callback = function()
		local c = vim.v.char
		if c == "-" then
			return -- a third dash is coming: this is "---", leave it
		end

		local col = vim.api.nvim_win_get_cursor(0)[2] -- bytes before cursor
		local before = vim.api.nvim_get_current_line():sub(1, col)

		-- Must end in exactly two dashes: the char before them is not a dash.
		-- (sub(-3,-3) is "" at line start, which also satisfies this.)
		if before:sub(-2) ~= "--" or before:sub(-3, -3) == "-" then
			return
		end

		-- The typed char isn't inserted yet; do the swap right after it lands.
		vim.schedule(function()
			local row, ccol = unpack(vim.api.nvim_win_get_cursor(0))
			local line = vim.api.nvim_get_current_line()
			local lhs = line:sub(1, ccol - #c - 2) -- text before the two dashes
			local new_line = lhs .. "&mdash;" .. line:sub(ccol - #c + 1)
			vim.api.nvim_set_current_line(new_line)
			vim.api.nvim_win_set_cursor(0, { row, ccol + 5 }) -- "&mdash;"(7) - "--"(2)
		end)
	end,
})
