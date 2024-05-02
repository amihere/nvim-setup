-- import lualine plugin safely
local status, lualine = pcall(require, "lualine")
if not status then
	return
end

-- get lualine nightfly theme
local lualine_theme = require("lualine.themes.ayu_dark")

-- configure lualine with modified theme
lualine.setup({
	options = {
		theme = lualine_theme,
		icons_enabled = false,
		section_separators = { left = "" },
		globalstatus = true,
	},

	sections = {
		lualine_x = { "filetype" },
		lualine_z = {},
	},
})
