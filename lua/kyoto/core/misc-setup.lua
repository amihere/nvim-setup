local augroup = vim.api.nvim_create_augroup
local kyotoGroup = augroup("kyoto", {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})

autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		vim.hl.on_yank({
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

-- auto resize command
autocmd({ "VimResized" }, {
	group = kyotoGroup,
	pattern = "*",
	command = "wincmd =",
})

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

-- Remove banner, and some other edits
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

-- Helpers

-- Delete the swapfile for the current buffer
local function delete_swapfile()
	local swapfile = vim.fn.swapname(vim.api.nvim_buf_get_name(0))

	if swapfile == "" then
		vim.notify("No swapfile found for this buffer.", vim.log.levels.INFO)
		return
	end

	local ok, err = os.remove(swapfile)
	if ok then
		vim.notify("Deleted swapfile: " .. swapfile, vim.log.levels.INFO)
	else
		vim.notify("Failed to delete swapfile: " .. (err or "unknown error"), vim.log.levels.ERROR)
	end
end

-- Optional: bind to a command
vim.api.nvim_create_user_command("DS", delete_swapfile, {})
