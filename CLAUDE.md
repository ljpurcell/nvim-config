Neovim Config
=============

Lyndon's Neovim configuration. Plugin manager: lazy.nvim — plugin specs in `lua/plugins/*.lua`, editor/LSP bootstrap in `after/plugin/`, filetype behaviour in `after/ftplugin/`. Treesitter is on the `main` branch (`require('nvim-treesitter').install(langs)` plus a `FileType` autocmd that calls `vim.treesitter.start()` and sets treesitter folding).

Reference Index
---------------

Do NOT load these at session start — consult a file only when its topic is relevant to the current task.

| File | Description |
|------|-------------|
| `.refs/markdown-writing.md` | Markdown authoring setup (wrap, spell + spelling-as-code-action, em-dash substitution, HTML-entity rendering, frontmatter + card snippets, marksman) and the conceal/render-markdown gotchas behind it |
| `.refs/plugin-gotchas.md` | Plugin behaviour worth remembering (flash label mechanics, LuaSnip node return contracts / jump indices / `fmta` gotchas) |

Conventions
-----------

- Verify config changes by running headless Neovim — parse-check with `nvim --headless -c "lua assert(loadfile('FILE'))" -c qa`, and assert option/keymap/extmark state in a real buffer before reporting a change done. This caught a real bug this session (render-markdown forcing `conceallevel=3`).
- Buffer-local `after/ftplugin` features guard against re-sourcing with `vim.b.<name>_loaded`; a fresh session (not `:e`) is needed to re-run them after edits.
