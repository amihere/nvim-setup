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

	-- configure custom mappings
	defaults = {
		mappings = {
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
