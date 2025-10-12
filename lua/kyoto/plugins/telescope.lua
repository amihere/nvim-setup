-- import telescope plugin safely
local telescope_setup, telescope = pcall(require, "telescope")
if not telescope_setup then
	return
end

-- import telescope actions safely
local actions_setup, actions = pcall(require, "telescope.actions")
if not actions_setup then
	return
end

-- configure telescope
telescope.setup({
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({}),
		},
	},
	pickers = {
		find_files = {
			theme = "dropdown",
			previewer = false,
		},
		git_files = {
			theme = "dropdown",
			previewer = false,
		},
		buffers = {
			theme = "ivy",
			initial_mode = "normal",
			sort_mru = true,
			ignore_current_buffer = true,
		},
		grep_string = {
			theme = "ivy",
		},
		help_tags = {
			theme = "ivy",
		},
		live_grep = {
			theme = "ivy",
		},
	},

	-- configure custom mappings
	defaults = {
		file_ignore_patterns = { "node_modules", "build/" },
		mappings = {
			n = {
				["d"] = require("telescope.actions").delete_buffer,
			},
			i = {
				["<C-k>"] = actions.move_selection_previous, -- move to prev result
				["<C-j>"] = actions.move_selection_next, -- move to next result
				["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist, -- send selected to quickfixlist
			},
		},
	},
})

-- Load Extensions
telescope.load_extension("ui-select")
telescope.load_extension("fzf")
telescope.load_extension("harpoon")
telescope.load_extension("git_worktree")
telescope.load_extension("luasnip")
