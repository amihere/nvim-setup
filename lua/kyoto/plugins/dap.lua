local dap = require("dap")

require("nvim-dap-virtual-text").setup()

-- Debugger Keymaps
vim.api.nvim_set_keymap("n", "<leader>dt", ":DapTerminate<CR>", { desc = "Terminate", noremap = true })
vim.api.nvim_set_keymap("n", "<leader>db", ":DapToggleBreakpoint<CR>", { desc = "Toggle breakpoint", noremap = true })
vim.api.nvim_set_keymap("n", "<leader>dc", ":DapContinue<CR>", { desc = "Start/Resume Debugger", noremap = true })
vim.api.nvim_set_keymap("n", "<leader>dr", ":DapToggleRepl<CR>", { desc = "Toggle Repl", noremap = true })
