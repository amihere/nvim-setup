-- import claudecode plugin safely
local setup, claudecode = pcall(require, "claudecode")
if not setup then
	return
end

claudecode.setup({})

local keymap = vim.keymap

-- session
keymap.set("n", "<leader>cc", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
keymap.set("n", "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude" })
keymap.set("n", "<leader>cq", "<cmd>ClaudeCodeClose<cr>", { desc = "Close Claude window" })
keymap.set("n", "<leader>cr", "<cmd>ClaudeCode --resume<cr>", { desc = "Resume Claude" })
keymap.set("n", "<leader>cC", "<cmd>ClaudeCode --continue<cr>", { desc = "Continue last Claude conversation" })
keymap.set("n", "<leader>cm", "<cmd>ClaudeCodeSelectModel<cr>", { desc = "Select Claude model" })

-- context
keymap.set("n", "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add current buffer to Claude" })
keymap.set("v", "<leader>cs", "<cmd>ClaudeCodeSend<cr>", { desc = "Send selection to Claude" })

-- tree integration: in oil buffers <leader>cs sends file under cursor
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "oil", "NvimTree", "neo-tree" },
	callback = function(ev)
		vim.keymap.set(
			"n",
			"<leader>cs",
			"<cmd>ClaudeCodeTreeAdd<cr>",
			{ buffer = ev.buf, desc = "Add file from tree to Claude" }
		)
	end,
})

-- diff accept / deny (active inside diff buffers Claude opens)
keymap.set("n", "<leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept Claude diff" })
keymap.set("n", "<leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny Claude diff" })
