local mason = require("mason-registry")
local jdtls_path = mason.get_package("jdtls"):get_install_path()

local equinox_launcher_path = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

local system = "linux"
if vim.fn.has("win32") then
	system = "win"
elseif vim.fn.has("mac") then
	system = "mac"
end
local config_path = vim.fn.glob(jdtls_path .. "/config_" .. system)

local lombok_path = jdtls_path .. "/lombok.jar"

local jdtls = require("jdtls")

local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

local bundles = {}
vim.list_extend(
	bundles,
	vim.split(vim.fn.glob(mason.get_package("java-test"):get_install_path() .. "/extension/server/*.jar"), "\n")
)
vim.list_extend(
	bundles,
	vim.split(
		vim.fn.glob(
			mason.get_package("java-debug-adapter"):get_install_path()
				.. "/extension/server/com.microsoft.java.debug.plugin-*.jar"
		),
		"\n"
	)
)

local config = {
	cmd = {
		vim.fn.expand("/Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home/bin/java"), -- or '/path/to/java17_or_newer/bin/java'

		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xmx1g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",

		"-javaagent:" .. lombok_path,

		"-jar",
		equinox_launcher_path,

		"-configuration",
		config_path,

		"-data",
		vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t"),
	},

	root_dir = require("jdtls.setup").find_root({
		".git",
		"mvnw",
		"gradlew",
		"pom.xml",
		"build.gradle",
	}),

	on_attach = require("kyoto.plugins.lsp.lspconfig").on_attach,
	capabilities = require("cmp_nvim_lsp").default_capabilities(),

	-- Here you can configure eclipse.jdt.ls specific settings
	-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
	-- for a list of options
	settings = {
		java = {
			server = { launchMode = "Hybrid" },
			eclipse = {
				downloadSources = true,
			},
			maven = {
				downloadSources = true,
			},
			configuration = {
				runtimes = {
					{
						name = "JavaSE-21",
						path = "/Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home",
					},
				},
			},
			references = {
				includeDecompiledSources = true,
			},
			implementationsCodeLens = {
				enabled = false,
			},
			referenceCodeLens = {
				enabled = true,
			},
			inlayHints = {
				parameterNames = {
					enabled = "none",
				},
			},
			signatureHelp = {
				enabled = true,
				description = {
					enabled = true,
				},
			},
			sources = {
				organizeImports = {
					starThreshold = 9999,
					staticStarThreshold = 9999,
				},
			},
		},
		redhat = { telemetry = { enabled = false } },
	},

	-- Language server `initializationOptions`
	-- You need to extend the `bundles` with paths to jar files
	-- if you want to use additional eclipse.jdt.ls plugins.
	--
	-- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
	--
	-- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
	init_options = {
		bundles = bundles,
		extendedClientCapabilities = extendedClientCapabilities,
	},
}

config["on_attach"] = function(client, bufnr)
	local _, _ = pcall(vim.lsp.codelens.refresh)
	require("jdtls").setup_dap({ hotcodereplace = "auto" })
	-- require("kyoto.plugins.lsp.lspconfig").on_attach(client, bufnr)
	local status_ok, jdtls_dap = pcall(require, "jdtls.dap")
	if status_ok then
		jdtls_dap.setup_dap_main_class_configs()
	end
end

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	pattern = { "*.java" },
	callback = function()
		local _, _ = pcall(vim.lsp.codelens.refresh)
	end,
})

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
jdtls.start_or_attach(config)
