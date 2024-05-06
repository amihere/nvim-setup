-- import lualine plugin safely
local status, lualine = pcall(require, "lualine")
if not status then
	return
end

-- get lualine nightfly theme
local lualine_theme = require("lualine.themes.ayu_dark")

lualine_theme.normal.a.bg = "#112233"
lualine_theme.visual.a.bg = "#112233"
lualine_theme.insert.a.bg = "#112233"
lualine_theme.normal.a.fg = "#f0f0f0"
lualine_theme.visual.a.fg = "#f0d0a0"
lualine_theme.insert.a.fg = "#f0b0b0"

-- configure lualine with modified theme
lualine.setup({
	options = {
		theme = lualine_theme,
		icons_enabled = false,
		section_separators = { left = "" },
		component_separators = { left = "" },
		globalstatus = true,
	},

	sections = {
		lualine_c = {
			function()
				return require("nvim-treesitter").statusline({
					indicator_size = 60,
					type_patterns = { "function", "method" },
					separator = " > ",
				})
			end,
		},
		lualine_x = { "filename" },
		lualine_z = {},
	},
})
