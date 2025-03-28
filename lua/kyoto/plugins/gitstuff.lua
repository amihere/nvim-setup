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

				map("n", "<leader>hB", gitsigns.blame, { desc = "blame line (full)" })

		map("n", "<leader>hdd", gitsigns.diffthis, { desc = "diff against index" })
		map("n", "<leader>hdb", ":Gitsigns change_base ", { desc = "change base to another branch/commit" })
		map("n", "<leader>hdr", gitsigns.reset_base, { desc = "reset base" })

		map("n", "<leader>hdD", function()
			gitsigns.diffthis("~")
		end, { desc = "diff against last commit" })

		map("n", "<leader>hQ", function()
			gitsigns.setqflist("all", nil)
		end, { desc = "open all hunks in qflist" })
		map("n", "<leader>hq", gitsigns.setqflist, { desc = "open hunks in buffer inside qflist" })

		-- Toggles
		map("n", "<leader>hb", gitsigns.toggle_current_line_blame, { desc = "toggle line blame" })
		map("n", "<leader>hw", gitsigns.toggle_word_diff, { desc = "toggle word diff" })

		-- Text object
		map({ "o", "x" }, "ih", gitsigns.select_hunk)

		local function get_branch(callback)
			local telescope = require("telescope.builtin")
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")
			telescope.git_branches({
				attach_mappings = function(prompt_bufnr)
					actions.select_default:replace(function()
						-- Get the selected branch
						local selection = action_state.get_selected_entry()

						if selection then
							-- Close Telescope window
							actions.close(prompt_bufnr)

							-- Extract branch name (remove asterisk and whitespace)
							local branch_name = selection.value:gsub("^*%s*", "")

							-- Call the provided callback with the branch name
							if callback and type(callback) == "function" then
								callback(branch_name)
							end
						end
					end)

					return true
				end,
			})
		end

		local function review_pr(branch_name)
			local gs = require("gitsigns")
			gs.change_base(branch_name, true, function()
				gs.setqflist("all", nil)
				print("Opening all hunks from branch: " .. branch_name)
			end)
		end

		vim.api.nvim_create_user_command("ReviewPR", function()
			get_branch(review_pr)
		end, {
			desc = "Open quickfix list with hunks diffed against selected branch",
		})
	end,
})

require("git-worktree").setup()
