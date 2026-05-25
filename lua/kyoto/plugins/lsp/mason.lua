-- import mason plugin safely
local mason_status, mason = pcall(require, "mason")
if not mason_status then
	return
end

local mason_lspconfig_status, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_status then
	return
end

-- enable mason
mason.setup()

mason_lspconfig.setup({
	-- list of servers for mason to install
	ensure_installed = {
		-- Lua
		"lua_ls",
		-- Elixir
		"elixirls",
		-- Python
		"pylsp",
		-- Front end
		"biome",
		"svelte",
		"cssls",
		"tailwindcss",
		"html",
		-- Java
		"jdtls",
		-- Go
		"gopls",
	},
	-- auto-install configured servers (with lspconfig)
	automatic_installation = true, -- not the same as ensure_installed
})

-- non-LSP tools (formatters, linters, code-action helpers) — single declaration point
local tool_installer_status, tool_installer = pcall(require, "mason-tool-installer")
if not tool_installer_status then
	return
end

tool_installer.setup({
	ensure_installed = {
		-- formatters (used by conform.nvim)
		"stylua",
		"gofumpt",
		"goimports",
		"prettier",
		"sqlfmt",
		"clang-format",
		-- linters (used by none-ls)
		"golangci-lint",
		"revive",
		-- Go code-action helpers (used by none-ls)
		"impl",
		"gomodifytags",
	},
})
