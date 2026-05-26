local lint_status, lint = pcall(require, "lint")
if not lint_status then
	return
end

-- nvim-lint linter names (NOT Mason package names):
--   golangci-lint → "golangcilint"   |   revive → "revive"
lint.linters_by_ft = {
	go = { "golangcilint", "revive" },
}

local lint_augroup = vim.api.nvim_create_augroup("kyoto-nvim-lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
	group = lint_augroup,
	callback = function()
		lint.try_lint()
	end,
})
