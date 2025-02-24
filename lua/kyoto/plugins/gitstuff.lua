-- import gitsigns plugin safely
local setup, _gitsigns = pcall(require, "gitsigns")
if not setup then
	return
end

-- configure/enable gitsigns
_gitsigns.setup({
	on_attach = function(bufnr)
		local gitsigns = require("gitsigns")
		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Navigation
		map("n", "]c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gitsigns.nav_hunk("next")
			end
		end, { desc = "move to next hunk" })

		map("n", "[c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gitsigns.nav_hunk("prev")
			end
		end, { desc = "move to previous hunk" })

		-- Actions
		map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "stage hunk" })
		map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "reset hunk" })

		map("v", "<leader>hs", function()
			gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "stage hunk" })

		map("v", "<leader>hr", function()
			gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "reset hunk" })

		map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "stage buffer" })
		map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "reset buffer" })
		map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "preview hunk" })
		map("n", "<leader>hi", gitsigns.preview_hunk_inline, { desc = "preview hunk inline" })

		map("n", "<leader>hb", function()
			gitsigns.blame_line({ full = true })
		end, { desc = "blame line (full)" })

		map("n", "<leader>hdd", gitsigns.diffthis, { desc = "diff against index" })
		map("n", "<leader>hdb", ":Gitsigns change_base ", { desc = "change base to another branch/commit" })
		map("n", "<leader>hdr", gitsigns.reset_base, { desc = "reset base" })

		map("n", "<leader>hdD", function()
			gitsigns.diffthis("~")
		end, { desc = "diff against last commit" })

		map("n", "<leader>hQ", function()
			gitsigns.setqflist("all")
		end, { desc = "open all hunks in qflist" })
		map("n", "<leader>hq", gitsigns.setqflist, { desc = "open hunks in buffer inside qflist" })

		-- Toggles
		map("n", "<leader>hB", gitsigns.toggle_current_line_blame, { desc = "toggle line blame" })
		map("n", "<leader>hw", gitsigns.toggle_word_diff, { desc = "toggle word diff" })

		-- Text object
		map({ "o", "x" }, "ih", gitsigns.select_hunk)
	end,
})

require("git-worktree").setup()

