-- Route LSP window/showMessage through vim.notify (which nvim-notify handles
-- as a toast). Installed via LspAttach autocmd so this runs *after* noice's
-- setup() has finished — otherwise noice's table-entry assignment of
-- vim.lsp.handlers["window/showMessage"] would overwrite ours. Noice's own
-- capture is disabled via lsp.message.enabled = false in its config, so the
-- handler slot stays ours after this autocmd fires.
vim.api.nvim_create_autocmd("LspAttach", {
	once = true,
	callback = function()
		vim.lsp.handlers["window/showMessage"] = function(_, result, ctx)
			local client = vim.lsp.get_client_by_id(ctx.client_id)
			local level = ({
				[1] = vim.log.levels.ERROR,
				[2] = vim.log.levels.WARN,
				[3] = vim.log.levels.INFO,
				[4] = vim.log.levels.INFO,
			})[result.type] or vim.log.levels.INFO
			vim.notify(result.message, level, {
				title = client and client.name or "LSP",
			})
		end
	end,
})
