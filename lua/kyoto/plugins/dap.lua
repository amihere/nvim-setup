local dap, dapui = require("dap"), require("dapui")

require("nvim-dap-virtual-text").setup()
dapui.setup()

dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end

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

vim.keymap.set("n", "<leader>df", function()
	dapui.eval(nil, { enter = true })
end, { desc = "Eval var under cursor", noremap = true })

vim.keymap.set({ "n" }, "<leader>dx", dapui.toggle, { desc = "Toggle dapui" })

