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

LuaSnip — node return contracts (build crux)
--------------------------------------------

- The single most common build error is mixing up what each node type's `fn` must **return**:
  - `function_node` (`f`) → must return a **string** (or list of strings). `tostring()` a number; never return a node (`return t('X')` errors — wrong type).
  - `dynamic_node` (`d`) → must return a **node**, specifically a `sn(...)` snippet node. Returning a raw `{ ... }` table of nodes, or a bare string, errors.
  - `choice_node` (`c`) → no fn; options are listed inline as its second arg.
- **Jump indices belong only to jumpable nodes** (`i`, `d`, `c`). `function_node` takes **no** index and is skipped on `<C-f>` — don't write `f(1, fn)` (the leading `1` is swallowed as the "function" arg; signature is `f(fn, argnode_refs, opts)`). Inside a `sn(...)`, indices are **local** and reset to `1`.
- A dynamic/function node can only **reference** another node by its jump index. A value derived purely from the buffer/environment (filename, line count) needs no reference — read it directly inside the fn. A function node fires once at expansion (and again only if a referenced node changes), so a buffer scan reflects state *at insert time*.
- **`fmta` literal text:** a Lua `[[ ]]` long-string captures every character, including leading indentation — keep heredoc lines flush at column 0 or the indent appears in the expanded output. The count of `<>` placeholders must equal the number of nodes in the table.
