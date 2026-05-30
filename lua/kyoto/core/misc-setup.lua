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

-- Copy the matching Makefile template (gradle/maven) into the project root.
-- Finds the root with vim.fs.root, same as ftplugin/java.lua. Use
-- :MakefileInit! to overwrite an existing Makefile.
local function makefile_init(opts)
	local root = vim.fs.root(0, { "gradlew", ".git", "mvnw" })
	if not root then
		vim.notify("No project root found above this buffer", vim.log.levels.ERROR)
		return
	end

	local kind
	if vim.uv.fs_stat(vim.fs.joinpath(root, "pom.xml")) then
		kind = "maven"
	elseif vim.uv.fs_stat(vim.fs.joinpath(root, "build.gradle")) or vim.uv.fs_stat(vim.fs.joinpath(root, "build.gradle.kts")) then
		kind = "gradle"
	else
		vim.notify("No pom.xml or build.gradle at project root: " .. root, vim.log.levels.ERROR)
		return
	end

	local dest = vim.fs.joinpath(root, "Makefile")
	if vim.uv.fs_stat(dest) and not opts.bang then
		vim.notify(dest .. " exists (use :MakefileInit! to overwrite)", vim.log.levels.WARN)
		return
	end

	local src = vim.fs.joinpath(vim.fn.stdpath("config"), "templates", "Makefile." .. kind)
	local ok, err = vim.uv.fs_copyfile(src, dest)
	if ok then
		vim.notify("Copied " .. kind .. " Makefile -> " .. dest, vim.log.levels.INFO)
	else
		vim.notify("Copy failed: " .. (err or "unknown error"), vim.log.levels.ERROR)
	end
end

vim.api.nvim_create_user_command("MakefileInit", makefile_init, {
	bang = true,
	desc = "Copy the matching Gradle/Maven Makefile template into the project root",
})

-- Run `make` with tab-completion of targets parsed from the project's Makefile.
-- Targets come from "target: ## desc" lines (the template format). :JJ sends
-- output to the quickfix list; :JJ! runs in a bottom terminal split (for
-- long-running targets like run). -C keeps it working from subdirectories.
local function make_targets()
	local root = vim.fs.root(0, { "Makefile" }) or vim.fn.getcwd()
	local makefile = vim.fs.joinpath(root, "Makefile")
	if not vim.uv.fs_stat(makefile) then
		return {}
	end
	local targets = {}
	for line in io.lines(makefile) do
		local t = line:match("^([%w_-]+):.*##")
		if t then
			table.insert(targets, t)
		end
	end
	return targets
end

vim.api.nvim_create_user_command("JJ", function(opts)
	local root = vim.fs.root(0, { "Makefile" }) or vim.fn.getcwd()
	local args = vim.fn.fnameescape(root) .. " " .. opts.args
	if opts.bang then
		vim.cmd("botright split | terminal make -C " .. args)
		vim.cmd("startinsert")
	else
		vim.cmd("make -C " .. args)
	end
end, {
	nargs = "*",
	bang = true,
	desc = "Run make: :JJ -> quickfix, :JJ! -> bottom terminal split (target completion)",
	complete = function(lead)
		return vim.tbl_filter(function(t)
			return t:find(lead, 1, true) == 1
		end, make_targets())
	end,
})
