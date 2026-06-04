Plugin Gotchas
==============

flash.nvim — labels
-------------------

- Labels are **single-character only**. The pool is the `labels` string plus its uppercase variants (plus any chars added), ~52 by default. Beyond the pool, extra matches get **no label** — flash has no multi-char (easymotion-style) labels, so on a very dense screen some matches are simply unreachable by label.
- `search.max_length` controls label-*skipping*: flash strips any label char that could be the next char of a continued search. A single common letter (`a`, `t`) therefore collapses the pool — almost every letter follows some match — so few/no labels show. Set `search.max_length = 1` so labels stop being skipped after one char.
  - Tradeoff: no multi-char narrowing *within* flash (use regular `/` search for that). This matches how Lyndon uses it — single-char flash hops, regular search for multi-char.
- Config: `lua/plugins/flash.lua`.

LuaSnip — helper return arity in node args
------------------------------------------

- A helper passed **inline** as a node argument (e.g. `i(1, kebab(title))`) must return **exactly one value**. A function whose last expression is `:gsub(...)` returns `(string, count)` — both values expand into the call, so the count lands in the next positional slot (`i`'s third arg, `opts`), and LuaSnip later crashes trying to index a number (`attempt to index local 'opts' (a number value)`, surfacing as `Error while evaluating dynamicNode@N`). Fix: bind to a local first (`local slug = (...):gsub(...) … ; return slug`) or wrap the whole chain in parens — both truncate to one value.
- **Headless tests can hide this.** `local x = f()` truncates extra returns, so a headless assertion on the *value* passes while the inline use still crashes. When a helper feeds straight into an argument list, assert its **arity** (`select("#", f(...)) == 1`), not just its result.
- **`nvim --headless -l` can't drive a live LuaSnip expansion.** `luasnip.expand()` needs insert-mode trigger detection, and `snippet_node`/dynamic-node construction is session-bound — both error or no-op under `-l`. So a green headless run proves helper logic only, **not** that the snippet expands. Confirm dynamic/function nodes interactively in a real buffer (fresh session) before calling it done.
