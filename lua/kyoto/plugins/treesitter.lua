-- import nvim-treesitter plugin safely
local status, treesitter = pcall(require, "nvim-treesitter")
if not status then
	return
end

-- ensure these language parsers are installed
local ensure_installed = {
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
}
treesitter.install(ensure_installed)

---@param buf integer
---@param language string
local function treesitter_try_attach(buf, language)
	-- check if parser exists and load it
	if not vim.treesitter.language.add(language) then
		return
	end
	-- enables syntax highlighting and other treesitter features
	vim.treesitter.start(buf, language)

	-- check if treesitter indentation is available for this language, and if so enable it
	-- in case there is no indent query, the indentexpr will fallback to the vim's built in one
	local has_indent_query = vim.treesitter.query.get(language, "indents") ~= nil

	-- enables treesitter based indentation
	if has_indent_query then
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end
end

local available_parsers = treesitter.get_available()
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		local buf, filetype = args.buf, args.match

		local max_filesize = 100 * 1024 -- 100 KB
		local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
		if ok and stats and stats.size > max_filesize then
			return
		end

		local language = vim.treesitter.language.get_lang(filetype)
		if not language then
			return
		end

		local installed_parsers = treesitter.get_installed("parsers")

		if vim.tbl_contains(installed_parsers, language) then
			-- enable the parser if it is installed
			treesitter_try_attach(buf, language)
		elseif vim.tbl_contains(available_parsers, language) then
			-- if a parser is available in `nvim-treesitter` auto install it, and enable it after the installation is done
			treesitter.install(language):await(function()
				treesitter_try_attach(buf, language)
			end)
		else
			-- try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
			treesitter_try_attach(buf, language)
		end
	end,
})

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true, desc = "Incremental selection (outer)" }
keymap("n", "<Enter>", ":normal van<cr>", opts)
keymap("v", "<Enter>", function()
	vim.api.nvim_feedkeys("an", "v", false)
end)

opts.desc = "Incremental selection (inner)"
keymap("n", "<S-Enter>", ":normal vin<cr>", opts)
keymap("v", "<S-Enter>", function()
	vim.api.nvim_feedkeys("in", "v", false)
end)
