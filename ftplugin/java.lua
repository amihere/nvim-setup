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
		"java", -- or '/path/to/java17_or_newer/bin/java'
		-- vim.fn.expand("/home/linuxbrew/.linuxbrew/Cellar/openjdk/21.0.3/bin/java"), -- or '/path/to/java17_or_newer/bin/java'
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-javaagent:" .. lombok_path,
		"-Xmx1g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",

		-- "-javaagent:" .. lombok_path,

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
	capabilities = require("cmp_nvim_lsp").default_capabilities(),

	-- Here you can configure eclipse.jdt.ls specific settings
	-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
	-- for a list of options
	settings = {
		java = {
			server = { launchMode = "Hybrid" },
			extendedClientCapabilities = extendedClientCapabilities,
			eclipse = {
				downloadSources = true,
			},
			format = {
				enabled = false,
				settings = {
					url = "~/.local/share/eclipse/eclipse-java-google-style.xml",
					profile = "GoogleStyle",
				},
			},
			gradle = {
				enabled = true,
			},
			maven = {
				downloadSources = true,
			},
			-- configuration = {
			-- 	runtimes = {
			-- 		{
			-- 			name = "JavaSE-17",
			-- 			path = "/home/linuxbrew/.linuxbrew/Cellar/openjdk@17/17.0.11",
			-- 		},
			-- 	},
			-- },
			references = {
				includeDecompiledSources = true,
			},
			implementationsCodeLens = {
				enabled = true,
			},
			referenceCodeLens = {
				enabled = true,
			},
			inlayHints = {
				parameterNames = {
					enabled = "all",
				},
			},
			signatureHelp = {
				enabled = true,
				description = {
					enabled = true,
				},
			},
			contentProvider = { preferred = "fernflower" }, -- Use fernflower to decompile library code

			-- Specify any completion options
			completion = {
				favoriteStaticMembers = {
					"org.hamcrest.MatcherAssert.assertThat",
					"org.hamcrest.Matchers.*",
					"org.hamcrest.CoreMatchers.*",
					"org.junit.jupiter.api.Assertions.*",
					"java.util.Objects.requireNonNull",
					"java.util.Objects.requireNonNullElse",
					"org.mockito.Mockito.*",
				},
				filteredTypes = {
					"com.sun.*",
					"io.micrometer.shaded.*",
					"java.awt.*",
					"jdk.*",
					"sun.*",
				},
			},
			-- How code generation should act
			codeGeneration = {
				toString = {
					template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
				},
				hashCodeEquals = {
					useJava7Objects = true,
				},
				useBlocks = true,
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

local function register_keybindings()
	local status_ok, which_key = pcall(require, "which-key")
	if not status_ok then
		return
	end

	local mappings = {
		mode = "n", -- NORMAL mode
		{ "<leader>J", group = "Java", nowait = true, remap = false },
		{
			"<leader>JC",
			jdtls.extract_constant,
			desc = "Extract Constant",
			nowait = true,
			remap = false,
		},
		{ "<leader>Jp", jdtls.pick_test, desc = "Pick Test", nowait = true, remap = false },
		{ "<leader>JT", jdtls.test_class, desc = "Test Class", nowait = true, remap = false },
		{ "<leader>Jc", "<Cmd>JdtCompile<CR>", desc = "Compile Java Code", nowait = true, remap = false },
		{
			"<leader>Jo",
			jdtls.organize_imports,
			desc = "Organize Imports",
			nowait = true,
			remap = false,
		},
		{
			"<leader>Js",
			"<Cmd>!mvn compile spring-boot:run<CR>",
			desc = "Run a spring boot app",
			nowait = true,
			remap = false,
		},
		{
			"<leader>Jt",
			jdtls.test_nearest_method,
			desc = "Test Method",
			nowait = true,
			remap = false,
		},
		{
			"<leader>Jv",
			jdtls.extract_variable,
			desc = "Extract Variable",
			nowait = true,
			remap = false,
		},
	}

	local vmappings = {
		{
			mode = { "v" },
			{ "<leader>J", group = "Java", nowait = true, remap = false },
			{
				"<leader>Jc",
				jdtls.extract_constant,
				desc = "Extract Constant",
				nowait = true,
				remap = false,
			},
			{
				"<leader>Jm",
				"<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>",
				desc = "Extract Method",
				nowait = true,
				remap = false,
			},
			{
				"<leader>Jv",
				"<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>",
				desc = "Extract Variable",
				nowait = true,
				remap = false,
			},
		},
	}

	which_key.add(mappings)
	which_key.add(vmappings)
end

config["on_attach"] = function(client, bufnr)
	local _, _ = pcall(vim.lsp.codelens.refresh)
	require("jdtls").setup_dap({ hotcodereplace = "auto" })
	require("kyoto.plugins.lsp.keybinds").on_attach(client, bufnr)
	local status_ok, jdtls_dap = pcall(require, "jdtls.dap")
	if status_ok then
		jdtls_dap.setup_dap_main_class_configs()
	end

	vim.o.tabstop = 4
	vim.o.shiftwidth = 0
	register_keybindings()
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
