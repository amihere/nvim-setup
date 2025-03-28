local M = {}

function M.on_attach(client, bufnr)
	local keymap = vim.keymap

	-- keybind options
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- set keybinds
	opts.desc = "Show LSP references"
	keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

	opts.desc = "Go to declaration"
	keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

	opts.desc = "Show LSP definitions"
	keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

	opts.desc = "Show LSP implementations"
	keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

	opts.desc = "Show LSP type definitions"
	keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

	opts.desc = "See available code actions"
	keymap.set({ "n", "v" }, "<leader>ra", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

	opts.desc = "Smart rename"
	keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

	opts.desc = "Show buffer diagnostics"
	keymap.set("n", "<leader>E", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

	opts.desc = "Show line diagnostics"
	keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts) -- show diagnostics for line

	opts.desc = "toggle inlay hints"
	keymap.set("n", "<leader>ri", function()
		vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
	end, opts) -- toggle inlay hints
	opts.desc = "Ask for signature help"

	keymap.set("n", "<leader>rh", function()
		vim.lsp.buf.signature_help()
		vim.lsp.buf.signature_help()
	end, opts)

	opts.desc = "Run Hover"
	keymap.set("n", "K", function()
		vim.lsp.buf.hover()
		vim.lsp.buf.hover()
	end, opts)
end

return M
