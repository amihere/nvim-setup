local dap, dapui = require("dap"), require("dapui")

require("nvim-dap-virtual-text").setup()

dapui.setup({
	controls = {
		element = "repl",
		enabled = false,
	},
	layouts = {
		{
			elements = {
				{
					id = "watches",
					size = 0.25,
				},
				{
					id = "breakpoints",
					size = 0.25,
				},
				{
					id = "scopes",
					size = 0.25,
				},
				{
					id = "stacks",
					size = 0.25,
				},
			},
			size = 60,
			position = "left", -- Can be "left" or "right"
		},
		{
			elements = {
				"console",
			},
			size = 12,
			position = "bottom", -- Can be "bottom" or "top"
		},
	},
})


dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end

-- Highlight debugger symbols
vim.fn.sign_define("DapStopped", { text = "→", texthl = "DapStopped", linehl = "DapStoppedLineHl" })
vim.api.nvim_set_hl(0, "DapStopped", { fg = "#00FF00", bg = "#444444", blend = 15 })
vim.api.nvim_set_hl(0, "DapStoppedLineHl", { bg = "#2a4f66", bold = true })
vim.fn.sign_define("DapBreakpoint", { text = "B", texthl = "DiagnosticSignError", linehl = "", numhl = "" })


-- Debugger Keymaps
vim.api.nvim_set_keymap("n", "<leader>dt", ":DapTerminate<CR>", { desc = "Terminate", noremap = true })
vim.api.nvim_set_keymap("n", "<leader>db", ":DapToggleBreakpoint<CR>", { desc = "Toggle breakpoint", noremap = true })
vim.api.nvim_set_keymap("n", "<leader>dc", ":DapContinue<CR>", { desc = "Start/Resume Debugger", noremap = true })
vim.api.nvim_set_keymap("n", "<leader>dr", ":DapToggleRepl<CR>", { desc = "Toggle Repl", noremap = true })
vim.api.nvim_set_keymap("n", "<leader>dj", ":DapStepOver<CR>", { desc = "Step Over Code", noremap = true })
vim.api.nvim_set_keymap("n", "<leader>dl", ":DapStepInto<CR>", { desc = "Step In Code", noremap = true })
vim.api.nvim_set_keymap("n", "<leader>dh", ":DapStepOut<CR>", { desc = "Step Out Of Code", noremap = true })
vim.api.nvim_set_keymap(
	"n",
	"<leader>dv",
	":DapVirtualTextToggle<CR>",
	{ desc = "Toggle Virtual Text", noremap = true }
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>d.",
	":lua require('dap').run_to_cursor()<CR>",
	{ desc = "Run to cursor location", noremap = true }
)
vim.keymap.set("n", "<leader>df", function()
	dapui.eval(nil, { enter = true })
end, { desc = "Eval var under cursor", noremap = true })

vim.keymap.set({ "n" }, "<leader>dx", dapui.toggle, { desc = "Toggle dapui" })

