return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPost", "BufWritePost", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- Custom linter: `sqlc compile` static-checks queries against the schema
		-- (and the sqlc annotation layer) without generating code. It's the only
		-- tool that understands `sqlc.arg`/`-- name:`, so a generic SQL LSP would
		-- only produce false positives on these files.
		--
		-- `cwd` resolves to the nearest ancestor holding sqlc.yaml, so this works
		-- regardless of which directory nvim was opened in.
		lint.linters.sqlc = {
			cmd = "sqlc",
			args = { "compile" },
			stdin = false,
			stream = "stderr",
			ignore_exitcode = true, -- sqlc exits non-zero on errors; we still parse them
			-- `cwd` must be a string (nvim-lint reads linter.cwd literally, no
			-- function eval) — it's set per-buffer in the autocmd below.
			parser = require("lint.parser").from_errorformat("%f:%l:%c: %m", {
				source = "sqlc",
				severity = vim.diagnostic.severity.ERROR,
			}),
		}

		lint.linters_by_ft = {
			sql = { "sqlc" },
		}

		-- Run on save / open. Only fires sqlc when an sqlc.yaml is found above the
		-- file, so non-sqlc SQL files stay silent rather than erroring.
		vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
			group = vim.api.nvim_create_augroup("nvim-lint-sql", { clear = true }),
			pattern = "*.sql",
			callback = function()
				local root = vim.fs.root(0, { "sqlc.yaml" })
				if root then
					-- Resolve the project root to a string and hand it to the
					-- linter just before running, so `sqlc compile` runs where
					-- sqlc.yaml lives regardless of nvim's cwd.
					lint.linters.sqlc.cwd = root
					lint.try_lint()
				end
			end,
		})
	end,
}
