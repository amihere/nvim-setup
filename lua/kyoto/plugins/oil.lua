require("oil").setup({
	view_options = {
		natural_order = false,
		show_hidden = true,
	},
	keymaps = {
		["gd"] = {
			desc = "Toggle file detail view",
			callback = function()
				detail = not detail
				if detail then
					require("oil").set_columns({ "permissions", "size", "mtime" })
				else
					require("oil").set_columns({})
				end
			end,
		},
	},

	columns = {
		"size",
	},
})
