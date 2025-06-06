-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps
---------------------

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>")

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- delete single character without copying into register
keymap.set("n", "x", '"_x')

-- window management
keymap.set("n", "<leader>|", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>-", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>q", "<C-w>q") -- close current split window
keymap.set("n", "<leader>w", "<C-w>w") -- toggle between open windows

----------------------
-- Plugin Keybinds
----------------------

-- telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>") -- find files within current working directory, respects .gitignore
keymap.set("n", "<leader>fr", "<cmd>Telescope resume<cr>") -- resume the previous list
keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>") -- find string in current working directory as you type
keymap.set("n", "<leader>fG", "<cmd>Telescope grep_string<cr>") -- find string under cursor in current working directory
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- list available help tags
keymap.set("n", "<leader>fF", "<cmd>silent! Telescope git_files<cr>") -- git file search
keymap.set("n", "<leader>fs", "<cmd>Telescope luasnip<cr>") -- open snippets for lang
keymap.set("n", "<leader>fc", "<cmd>Telescope colorscheme<cr>") -- show colors
keymap.set("n", "<leader>fC", "<cmd>Telescope commands<cr>") -- opens command list
keymap.set("n", "<leader>fv", "<cmd>Oil<cr>", { desc = "Open File Tree" })
keymap.set("n", "<leader>fn", vim.lsp.buf.format, { desc = "Format file" })
keymap.set("n", "<leader>fx", function()
	require("telescope.builtin").find_files({
		cwd = vim.fn.stdpath("config"),
	})
end, { desc = "view files in nvim config" })
keymap.set("n", "<leader>fss", function()
	require("telescope.builtin").find_files({
		cwd = vim.fn.stdpath("data"),
	})
end, { desc = "find file in nvim source" })
keymap.set("n", "<leader>fsg", function()
	require("telescope.builtin").live_grep({
		cwd = vim.fn.stdpath("data"),
	})
end, { desc = "grep nvim source" })

keymap.set(
	"n",
	"<leader>fa",
	"<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>",
	{ desc = "All symbols" }
)
keymap.set(
	"n",
	"<leader>fo",
	"<cmd>lua require('telescope.builtin').lsp_document_symbols({symbols = {'function', 'method'} })<cr>",
	{ desc = "Filter methods/functions" }
) -- filter methods/functions
keymap.set(
	"n",
	"<leader>fww",
	"<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<cr>",
	{ desc = "Open worktrees", silent = true }
) -- git worktrees
keymap.set(
	"n",
	"<leader>fwc",
	"<cmd>lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>",
	{ desc = "Create worktrees", silent = true }
) -- create git worktree

keymap.set("n", "<leader>rs", ":LspRestart<CR>") -- mapping to restart lsp if necessary

-- open git terminal
keymap.set("n", "<leader>zz", "<cmd>silent !tmux neww lazygit<CR>", { desc = "Open Git" })

keymap.set("n", "<leader>Z", ":silent !tmux splitw -l 20 -d ", { desc = "Start a new script..." })

keymap.set("n", "<leader>o", "zi", { desc = "Toggle all folds" })

-- run elixir commands
keymap.set(
	"n",
	"<leader>zx",
	"<cmd>silent !tmux splitw -l 20 -d iex -S mix<CR>",
	{ desc = "Run Elixir Mix in new tab" }
)

keymap.set("n", "<leader>zX", function()
	vim.cmd(":silent !tmux send-keys -t 1 'recompile' C-m")
end, { desc = "Reload Elixir server running in tab 1" })

keymap.set(
	"n",
	"<leader>zb",
	"<cmd>silent !tmux splitw -l 20 -d mix run --no-halt<CR>",
	{ desc = "Run Elixir process as prod" }
)

-- harpoon
keymap.set("n", "<leader>a", "<cmd>lua require('harpoon.mark').add_file()<cr>")
keymap.set("n", "<C-e>", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>") -- harpoon quick command
keymap.set("n", "<leader>.", "<cmd>lua require('harpoon.ui').nav_next()<cr>")
keymap.set("n", "<leader>,", "<cmd>lua require('harpoon.ui').nav_prev()<cr>")

-- moving lines up and down
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- move line below up, and keep cursor stationary
keymap.set("n", "J", "mzJ`z")

-- keep cursor in middle while going up/down
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")

-- keep cursor in middle when searching
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- keeps original copied text when pasting over another selected text
keymap.set("x", "<leader>p", [["_dP]])

-- will copy text into both copy buffer and system clipboard
keymap.set({ "n", "v" }, "<leader>y", [["+y]])
keymap.set("n", "<leader>Y", [["+Y]])
keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- This is going to get me cancelled
keymap.set("i", "<C-c>", "<Esc>")

keymap.set("n", "Q", "<nop>")
-- keymap.set("n", "<C-f>", "<cmd>silent !~/.local/bin/tmux-sessionizer<CR>")

keymap.set("n", "<C-n>", "<cmd>cnext<CR>zz")
keymap.set("n", "<C-p>", "<cmd>cprev<CR>zz")
keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
keymap.set("n", "<leader>xx", "<cmd>!chmod +x %<CR>", { silent = true })

keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
end)

keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- twilight
keymap.set("n", "<leader>ll", "<cmd>Twilight<cr>") -- toggle the twilight option

-- lines
keymap.set("n", "<leader>ln", "<cmd>set rnu!<cr>")

-- open a terminal
keymap.set("t", "<ESC>", "<C-\\><C-n>", { silent = true, desc = "Escape terminal mode" })
keymap.set("n", "<leader>tt", function()
	vim.cmd.vnew()
	vim.cmd.term()
	vim.cmd.wincmd("J")
	vim.cmd.startinsert()
end, { silent = true, desc = "Open large terminal" })

keymap.set("n", "<leader>ts", function()
	vim.cmd.vnew()
	vim.cmd.term()
	vim.cmd.wincmd("J")
	vim.api.nvim_win_set_height(0, 5)
	vim.cmd.startinsert()
end, { silent = true, desc = "Open a smaller terminal" })
