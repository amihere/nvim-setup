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
