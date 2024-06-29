require("oil").setup({
	view_options = {
		natural_order = false,
		is_always_hidden = function(name, bufnr)
			vim.startswith(name, "..")
		end,
	},

	columns = {
		"size",
	},
})
