local conform_status, conform = pcall(require, "conform")
if not conform_status then
	return
end

conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "goimports", "gofumpt" },
		elixir = { "mix" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
		svelte = { "prettier" },
		html = { "prettier" },
		css = { "prettier" },
		json = { "prettier" },
		yaml = { "prettier" },
		markdown = { "prettier" },
		sql = { "sqlfmt" },
		c = { "clang-format" },
		cpp = { "clang-format" },
	},
	format_on_save = function(bufnr)
		-- Java is handled by ftplugin/java.lua (jdtls + eclipse.xml profile)
		if vim.bo[bufnr].filetype == "java" then
			return nil
		end
		return { timeout_ms = 500, lsp_format = "never" }
	end,
	formatters = {
		prettier = {
			prepend_args = { "--no-semi", "--single-quote", "--jsx-single-quote" },
		},
	},
})

vim.keymap.set({ "n", "v" }, "<leader>fn", function()
	conform.format({ async = true, lsp_format = "fallback", timeout_ms = 500 })
end, { desc = "Format file (conform → LSP fallback)" })
