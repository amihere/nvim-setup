-- import nvim-treesitter plugin safely
local status, treesitter = pcall(require, "nvim-treesitter.configs")
if not status then
	return
end

-- configure treesitter
treesitter.setup({
	-- enable syntax highlighting
	highlight = {
		enable = true,
		disable = function(_, buf)
			local max_filesize = 100 * 1024 -- 100 KB
			---@diagnostic disable-next-line: undefined-field
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
		end,
	},
	-- enable indentation
	indent = { enable = true },
	-- enable autotagging (w/ nvim-ts-autotag plugin)
	autotag = { enable = true },
	-- ensure these language parsers are installed
	ensure_installed = {
		"bash",
		"css",
		"dockerfile",
		"eex",
		"elixir",
		"erlang",
		"gitignore",
		"heex",
		"html",
		"java",
		"javascript",
		"json",
		"lua",
		"python",
		"svelte",
		"typescript",
		"vim",
		"vimdoc",
	},

	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<Enter>",
			scope_incremental = false,
			node_incremental = "<Enter>",
			node_decremental = "<Backspace>",
		},
	},
	sync_install = false,
	-- auto install above language parsers
	auto_install = true,
})
