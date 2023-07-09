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
keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>sx", ":close<CR>") -- close current split window

----------------------
-- Plugin Keybinds
----------------------

-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>") -- toggle file explorer

-- telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>") -- find files within current working directory, respects .gitignore
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>") -- find string in current working directory as you type
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>") -- find string under cursor in current working directory
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
keymap.set("n", "<leader>fj", "<cmd>Telescope help_tags<cr>") -- list available help tags

keymap.set("n", "<leader>fh", "<cmd>Telescope harpoon marks<cr>") -- open harpoon list

-- telescope git commands (not on youtube nvim video)
keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>") -- list all git commits (use <cr> to checkout) ["gc" for git commits]
keymap.set("n", "<leader>gfc", "<cmd>Telescope git_bcommits<cr>") -- list git commits for current file/buffer (use <cr> to checkout) ["gfc" for git file commits]
keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>") -- list git branches (use <cr> to checkout) ["gb" for git branch]
keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>") -- list current changes per file with diff preview ["gs" for git status]

-- restart lsp server (not on youtube nvim video)
keymap.set("n", "<leader>rs", ":LspRestart<CR>") -- mapping to restart lsp if necessary

-- setup git terminal
keymap.set("n", "<leader>zz", ":FloatermNew --height=1.0 --width=1.0 lazygit<CR>")
keymap.set("n", "<leader>bb", ":FloatermNew --wintype=split ") -- open prompt to launch command
keymap.set("n", "<leader>bt", ":FloatermNew --wintype=split <CR>") -- opens the terminal
keymap.set("t", "<ESC>", "<cmd>FloatermToggle<cr>")

-- run elixir commands
keymap.set("n", "<leader>zx", ":FloatermNew iex -S mix<CR>")

-- the prime aegean

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

keymap.set("n", "Q", "<nop>")

-- harpoon
keymap.set("n", "<leader>hn", "<cmd>lua require('harpoon.mark').add_file()<cr>")
keymap.set("n", "<leader>hh", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>") -- harpoon quick command
keymap.set("n", "<leader>.", "<cmd>lua require('harpoon.ui').nav_next()<cr>")
keymap.set("n", "<leader>,", "<cmd>lua require('harpoon.ui').nav_prev()<cr>")

-- navigate to previous window, using tmux

keymap.set("n", "<leader>fa", vim.lsp.buf.format)
keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
end)
