-- diagnostics + Go code-actions only.
-- Formatting lives in lua/kyoto/plugins/conform.lua (conform.nvim).

local setup, null_ls = pcall(require, "null-ls")
if not setup then
	return
end

local diagnostics = null_ls.builtins.diagnostics
local code_actions = null_ls.builtins.code_actions

null_ls.setup({
	sources = {
		diagnostics.golangci_lint,
		diagnostics.revive,
		code_actions.impl,
		code_actions.gomodifytags,
	},
})
