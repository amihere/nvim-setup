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

-- remove trailing whitespace 
autocmd({ "BufWritePre" }, {
	group = kyotoGroup,
	pattern = "*",
	command = [[%s/\s\+$//e]],
})

-- Remove banner, and some other edits
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
