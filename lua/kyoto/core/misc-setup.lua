local augroup = vim.api.nvim_create_augroup
local kyotoGroup = augroup("kyoto", {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})

autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 40,
		})
	end,
})

// Allow C-x, C-f to start from current folder
autocmd("InsertEnter", {
	group = kyotoGroup,
	pattern = "*",
	callback = function()
		vim.cmd("let save_cwd = getcwd() | set autochdir")
	end,
})

autocmd("InsertLeave", {
	group = kyotoGroup,
	pattern = "*",
	callback = function()
		vim.cmd("set noautochdir | execute 'cd' fnameescape(save_cwd)")
	end,
})

autocmd({ "BufWritePre" }, {
	group = kyotoGroup,
	pattern = "*",
	command = [[%s/\s\+$//e]],
})

-- Remove banner, and some other edits
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
