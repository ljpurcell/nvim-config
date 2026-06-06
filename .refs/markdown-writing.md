Markdown Authoring Setup
========================

Lyndon writes blog posts and code docs/READMEs in Markdown. Features live in `after/ftplugin/markdown.lua` unless noted.

Editing comfort
---------------

- Soft wrap for prose: `wrap` + `linebreak` + `breakindent`. `j`/`k` are remapped to visual-line motion but stay count-aware (`5j` still jumps 5 real lines).
- Spell: `spell` on, `spelllang = en_au`. Native `]s`/`[s` jump between misspellings (spelling is not a diagnostic, so `]d`/`[d` won't reach it).

Spelling as a code action
-------------------------

- `<leader>ca` is the LSP code-action map (set buffer-local in `lua/plugins/lsp.lua` on `LspAttach`). In markdown it's overridden: when the word under the cursor is misspelled it offers spelling suggestions via `vim.ui.select` (→ telescope-ui-select) plus "add to dictionary" (`zg`) and "ignore this session" (`zG`); otherwise it falls back to `vim.lsp.buf.code_action()`.
- The override is **re-asserted on `LspAttach`** inside the ftplugin — otherwise marksman attaching would clobber it, because `LspAttach` fires after `FileType`.
- Replacement uses `idx z=` (`spellsuggest` and `z=` share ordering) — escaping-safe even for multi-word suggestions like "a lot".

"--" → "&mdash;"
----------------

- `InsertCharPre` converts `--` to `&mdash;` but leaves `---` alone (horizontal rule / frontmatter fence). A plain `:iabbrev` can't do this — it fires on the next char and can't look ahead, and typing the 3rd `-` of `---` would itself expand `--`. So conversion is **one keystroke late**: it fires when the char *after* `--` is typed and isn't another `-`.

HTML entity rendering (+ the conceal gotchas)
---------------------------------------------

- Common entities (`&mdash;`, `&amp;`, …) render as their glyph via extmark `conceal`, refreshed on `TextChanged`/`InsertLeave`. The entity stays raw on the cursor's line (`concealcursor = ""`) so it's editable.
- **Gotcha 1 — colour:** an extmark `conceal` cchar is coloured by the extmark's `hl_group`; without it the glyph uses the dim `Conceal` group and looks invisible. Set `hl_group = "Normal"`.
- **Gotcha 2 — conceallevel:** render-markdown forces rendered `conceallevel = 3`, at which Vim hides concealed text with **no cchar drawn at all** — the glyph vanishes off the cursor line. Set render-markdown `win_options.conceallevel.rendered = 2` (in `lua/plugins/render-markdown.lua`) so cchars render. **Both gotchas must be fixed together** — colour alone is irrelevant while level 3 suppresses the cchar.

Frontmatter snippet
-------------------

- LuaSnip snippet in `lua/plugins/completion.lua` (alongside the `go`/`ie` one), trigger `frontmatter`, markdown filetype. Matches the blog's Astro `posts` schema/conventions (`title`, `description`, `is_published`, `in_progress`, `slug`, `created_at`).
- `created_at` uses a **function node** (`os.date` at expand time) — not a plain value, which would freeze to config-load time. Jump fields with `<C-f>`/`<C-b>` (Lyndon's LuaSnip keys); gloss/voice fields are left as marked placeholders for Lyndon to write.
- `slug` is a **dynamic node** (`d(5, fn, {1})`) that derives from the `title` node via a `kebab()` helper (lowercase, runs of non-alphanumerics → single `-`, trimmed at ends) and updates live as the title is typed — yet stays editable for a manual override. This replaced a static `slug` placeholder that defaulted to `"slug"` and caused duplicate slugs across drafts. Editing the title *after* hand-customising the slug regenerates it (dynamic-node behaviour). Uniqueness depends on titles differing — there is deliberately no timestamp suffix (keeps URLs clean).

Card snippet
-----------

- LuaSnip snippet in `lua/plugins/completion.lua` (sibling of `frontmatter`), trigger `card`, markdown filetype. Authors a flashcard block: `--- / Deck: <name> / Tags: <tag> / --- / <n>. <body>`. Apparent purpose is seeding Anki cards — deck = filename, and the two tag sets mirror the Knowledge vs Habits decks (see global `.refs/learning-approach.md`).
- **Deck** — function node, `vim.fn.expand('%:t:r')` (filename, no dir/ext). Computed and skipped on jump; not editable. To make it hand-editable you'd swap `f` for an indexed `i`/`d`.
- **Tags** — dynamic node `d(1, fn)` (no argnode refs) that reads the filename *itself* and returns `sn(nil, { c(1, {...}) })`: a choice node whose options branch on the filename (`knowledge` → technical/concepts/words; else social/disposition/actions). No cross-node reference is used or possible — the deck is a function node, which has no jump index to reference.
- **Card number** — function node scanning the buffer (`nvim_buf_get_lines`) and counting card blocks (a `Deck: ` line bracketed by `---` above and `Tags: ` below, with `nil` guards at buffer edges). Returns `tostring(count)` with **no +1**: at expansion the new card's own lines are already in the buffer, so it counts itself (verified in a real buffer, per the project convention).
- **Body** — `i(0)` final stop, after `<n>. `.
- Keystrokes: `card` `<C-y>` (expand) → `<C-l>` cycles the tag choice → `<C-f>` jumps to the body (deck/number are skipped; function nodes take no jump index). `<C-b>` jumps back.

Other markdown plugins
----------------------

- `marksman` LSP (via mason, in `lua/plugins/lsp.lua`): link-anchor completion, heading rename + find-references, document symbols (`<leader>ds`).
- Treesitter `markdown` + `markdown_inline` parsers (also gives heading-based folding).
- `render-markdown.nvim` for in-buffer rendering.
- Formatting: prettier for markdown on save with `--prose-wrap preserve` (in `lua/plugins/format.lua`) — preserves frontmatter and hand-wrapped prose.
