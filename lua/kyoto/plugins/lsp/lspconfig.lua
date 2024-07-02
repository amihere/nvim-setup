-- import lspconfig plugin safely
local lspconfig_status, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status then
	return
end

-- import cmp-nvim-lsp plugin safely
local cmp_nvim_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_nvim_lsp_status then
	return
end

-- enable keybinds only for when lsp server available
local on_attach = require("kyoto.plugins.lsp.keybinds").on_attach

-- used to enable autocompletion (assign to every lsp server config)
local capabilities =
	vim.tbl_deep_extend("force", {}, vim.lsp.protocol.make_client_capabilities(), cmp_nvim_lsp.default_capabilities())

-- Change the Diagnostic symbols in the sign column (gutter)
local signs = { Error = " ", Warn = " ", Hint = "󱐋", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- configure lua server (with special settings)
lspconfig["lua_ls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	settings = { -- custom settings for lua
		Lua = {
			-- make the language server recognize "vim" global
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				-- make language server aware of runtime files
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
			},
		},
	},
})

lspconfig.pylsp.setup({
	on_attach = on_attach, -- this may be required for extended functionalities of the LSP
	capabilities = capabilities,
	flags = {
		debounce_text_changes = 150,
	},
})

lspconfig.gopls.setup({
	on_attach = on_attach, -- this may be required for extended functionalities of the LSP
	capabilities = capabilities,
	flags = {
		debounce_text_changes = 150,
	},
})

lspconfig.biome.setup({
	on_attach = on_attach, -- this may be required for extended functionalities of the LSP
	capabilities = capabilities,
	flags = {
		debounce_text_changes = 150,
	},
})

-- configure css server
lspconfig["cssls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure tailwindcss server
lspconfig["tailwindcss"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = { "typescript", "javascript", "svelte", "html", "css" },
})

-- configure svelte server
lspconfig["svelte"].setup({
	capabilities = capabilities,
	filetypes = { "typescript", "javascript", "svelte", "html", "css" },
	on_attach = function(client, bufnr)
		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = { "*.js", "*.ts" },
			callback = function(ctx)
				if client.name == "svelte" then
					client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
				end
			end,
		})
	end,
})

local capable = vim.lsp.protocol.make_client_capabilities()
capable.textDocument.completion.completionItem.snippetSupport = true
lspconfig.html.setup({
	capabilities = capable,
	flags = {
		debounce_text_changes = 150,
	},
})

-- Configure ElixirLS as the LSP server for Elixir.
lspconfig.elixirls.setup({
	cmd = { "/usr/local/opt/elixir-ls/libexec/language_server.sh" },
	on_attach = on_attach, -- this may be required for extended functionalities of the LSP
	capabilities = capabilities,
	flags = {
		debounce_text_changes = 150,
	},
	elixirLS = {
		dialyzerEnabled = false,
		fetchDeps = false,
	},
})
