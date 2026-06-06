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

vim.diagnostic.config({
	virtual_text = true,
	severity_sort = true,
	update_in_insert = false,
	float = { border = "rounded" },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = signs.Error,
			[vim.diagnostic.severity.WARN] = signs.Warn,
			[vim.diagnostic.severity.HINT] = signs.Hint,
			[vim.diagnostic.severity.INFO] = signs.Info,
		},
	},
})

vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = {
		".git",
		".luarc.json",
		".luarc.jsonc",
		".luacheckrc",
		"stylua.toml",
		".stylua.toml",
	},
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if
				path ~= vim.fn.stdpath("config")
				and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
			then
				return
			end
		end

		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
			runtime = {
				-- Tell the language server which version of Lua you're using (most
				-- likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
				-- Tell the language server how to find Lua modules same way as Neovim
				-- (see `:h lua-module-load`)
				path = {
					"lua/?.lua",
					"lua/?/init.lua",
				},
			},
			-- Make the server aware of Neovim runtime files
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
				},
			},
		})
	end,
	on_attach = on_attach,
	settings = {
		Lua = {},
	},
})

vim.lsp.config("pylsp", {
	on_attach = on_attach, -- this may be required for extended functionalities of the LSP
	capabilities = capabilities,
	settings = {
		pylsp = {
			plugins = {
				pycodestyle = {
					ignore = { "W391" },
					maxLineLength = 100,
				},
			},
		},
	},
})

vim.lsp.config("gopls", {
	on_attach = on_attach, -- this may be required for extended functionalities of the LSP
	capabilities = capabilities,
})

vim.lsp.config("biome", {
	on_attach = on_attach, -- this may be required for extended functionalities of the LSP
	capabilities = capabilities,
})

vim.lsp.config("lemminx", {
	on_attach = on_attach, -- this may be required for extended functionalities of the LSP
	capabilities = capabilities,
})

-- configure css server
vim.lsp.config("cssls", {
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure tailwindcss server
vim.lsp.config("tailwindcss", {
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = { "typescript", "javascript", "svelte", "html", "css" },
})

vim.lsp.config("ts_ls", {
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure svelte server
vim.lsp.config("svelte", {
	capabilities = capabilities,
	filetypes = { "svelte" },
	on_attach = function(client, bufnr)
		on_attach(client, bufnr)

		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = { "*.js", "*.ts" },
			group = vim.api.nvim_create_augroup("lspconfig.svelte", {}),
			callback = function(ctx)
				-- internal API to sync changes that have not yet been saved to the file system
				client:notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
			end,
		})
		vim.api.nvim_buf_create_user_command(bufnr, "LspMigrateToSvelte5", function()
			client:exec_cmd({
				title = "Migrate Component to Svelte 5 Syntax",
				command = "migrate_to_svelte_5",
				arguments = { vim.uri_from_bufnr(bufnr) },
			})
		end, { desc = "Migrate Component to Svelte 5 Syntax" })
	end,
})

local capable = vim.lsp.protocol.make_client_capabilities()
capable.textDocument.completion.completionItem.snippetSupport = true
vim.lsp.config("html", {
	capabilities = capable,
})

-- Configure ElixirLS as the LSP server for Elixir.
vim.lsp.config("elixirls", {
	on_attach = on_attach, -- this may be required for extended functionalities of the LSP
	capabilities = capabilities,
	settings = {
		elixirLS = {
			dialyzerEnabled = false,
			fetchDeps = false,
			projectDir = ".",
		},
	},
})

-- SchemaStore catalog feeds jsonls/yamlls with schemas for k8s, GH Actions,
-- docker-compose, OpenAPI, package.json, tsconfig, etc.
local schemastore_ok, schemastore = pcall(require, "schemastore")

vim.lsp.config("jsonls", {
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		json = {
			schemas = schemastore_ok and schemastore.json.schemas() or nil,
			validate = { enable = true },
		},
	},
})

vim.lsp.config("yamlls", {
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		yaml = {
			-- disable yamlls' built-in store so SchemaStore.nvim drives schemas
			schemaStore = {
				enable = false,
				url = "",
			},
			schemas = schemastore_ok and schemastore.yaml.schemas() or nil,
			keyOrdering = false,
		},
	},
})

vim.lsp.config("taplo", {
	on_attach = on_attach,
	capabilities = capabilities,
})

vim.lsp.config("dockerls", {
	on_attach = on_attach,
	capabilities = capabilities,
})

vim.lsp.config("docker_compose_language_service", {
	on_attach = on_attach,
	capabilities = capabilities,
})

vim.lsp.config("sqls", {
	on_attach = on_attach,
	capabilities = capabilities,
})

vim.lsp.enable({
	"lua_ls",
	"pylsp",
	"gopls",
	"biome",
	"lemminx",
	"cssls",
	"tailwindcss",
	"ts_ls",
	"svelte",
	"html",
	"elixirls",
	"jsonls",
	"yamlls",
	"taplo",
	"dockerls",
	"docker_compose_language_service",
})
