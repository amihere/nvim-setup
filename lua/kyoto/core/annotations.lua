-- Virtual-text code annotations that never touch the source file.
-- Store: vim.fn.stdpath("data") .. "/kyoto-annotations/annotations.json"
-- Anchor: line number + sha256 of the original line content (re-anchor on load).

local api = vim.api
local fn = vim.fn

local M = {}

local ns = api.nvim_create_namespace("kyoto-annotations")
local data_dir = fn.stdpath("data") .. "/kyoto-annotations"
local store_path = data_dir .. "/annotations.json"
local search_window = 50

api.nvim_set_hl(0, "KyotoAnnotation", { link = "Comment", italic = true, default = true })

-- M.state[bufnr] = { path, entries = { [extmark_id] = entry }, orphans = { entry, ... }, visible }
M.state = {}

-- ---------- storage ----------------------------------------------------------

local function ensure_data_dir()
	if fn.isdirectory(data_dir) == 0 then
		fn.mkdir(data_dir, "p")
	end
end

local function load_store()
	if fn.filereadable(store_path) == 0 then
		return {}
	end
	local ok, content = pcall(fn.readfile, store_path)
	if not ok or not content or #content == 0 then
		return {}
	end
	local decoded_ok, decoded = pcall(fn.json_decode, table.concat(content, "\n"))
	if not decoded_ok or type(decoded) ~= "table" then
		return {}
	end
	return decoded
end

local function save_store(store)
	ensure_data_dir()
	local tmp = store_path .. ".tmp"
	local encoded = fn.json_encode(store)
	fn.writefile({ encoded }, tmp)
	os.rename(tmp, store_path)
end

-- ---------- helpers ----------------------------------------------------------

local function hash_line(line)
	return fn.sha256(line or "")
end

local function now_iso()
	return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

local function trim(s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function buf_path(bufnr)
	if not api.nvim_buf_is_valid(bufnr) then
		return nil
	end
	if vim.bo[bufnr].buftype ~= "" then
		return nil
	end
	local name = api.nvim_buf_get_name(bufnr)
	if name == "" then
		return nil
	end
	return fn.fnamemodify(name, ":p")
end

-- ---------- rendering --------------------------------------------------------

local function render_entry(bufnr, entry)
	local line_idx = entry.line - 1
	if line_idx < 0 then
		line_idx = 0
	end
	local lines = vim.split(entry.text or "", "\n", { plain = true })
	local first = lines[1] or ""
	local rest = {}
	for i = 2, #lines do
		table.insert(rest, { { "  " .. lines[i], "KyotoAnnotation" } })
	end
	local opts = {
		virt_text = { { "  ▎ " .. first, "KyotoAnnotation" } },
		virt_text_pos = "eol",
		hl_mode = "combine",
	}
	if #rest > 0 then
		opts.virt_lines = rest
	end
	return api.nvim_buf_set_extmark(bufnr, ns, line_idx, 0, opts)
end

local function clear_buffer(bufnr)
	api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

-- ---------- anchor / load ----------------------------------------------------

local function find_anchor(bufnr, entry, line_count)
	local idx = entry.line - 1
	if idx >= 0 and idx < line_count then
		local line = api.nvim_buf_get_lines(bufnr, idx, idx + 1, false)[1] or ""
		if hash_line(line) == entry.hash then
			return idx + 1
		end
	end
	for delta = 1, search_window do
		for _, candidate in ipairs({ idx - delta, idx + delta }) do
			if candidate >= 0 and candidate < line_count then
				local line = api.nvim_buf_get_lines(bufnr, candidate, candidate + 1, false)[1] or ""
				if hash_line(line) == entry.hash then
					return candidate + 1
				end
			end
		end
	end
	return nil
end

local function load_buffer(bufnr)
	local path = buf_path(bufnr)
	if not path then
		return
	end
	local store = load_store()
	local file_entries = store[path] or {}
	local line_count = api.nvim_buf_line_count(bufnr)
	clear_buffer(bufnr)
	local state = { path = path, entries = {}, orphans = {}, visible = true }
	for _, entry in ipairs(file_entries) do
		local resolved = find_anchor(bufnr, entry, line_count)
		if resolved then
			entry.line = resolved
			local id = render_entry(bufnr, entry)
			state.entries[id] = entry
		else
			table.insert(state.orphans, entry)
		end
	end
	M.state[bufnr] = state
end

-- ---------- persistence ------------------------------------------------------

local function collect_buffer_entries(bufnr)
	local state = M.state[bufnr]
	if not state then
		return nil
	end
	local results = {}
	if state.visible then
		local extmarks = api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
		for _, mark in ipairs(extmarks) do
			local id, row = mark[1], mark[2]
			local entry = state.entries[id]
			if entry then
				local current_line = api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
				entry.line = row + 1
				entry.hash = hash_line(current_line)
				entry.snippet = trim(current_line)
				table.insert(results, entry)
			end
		end
	else
		-- annotations hidden, no live extmarks; keep stored line numbers as-is
		for _, entry in pairs(state.entries) do
			table.insert(results, entry)
		end
	end
	for _, o in ipairs(state.orphans) do
		table.insert(results, o)
	end
	return results
end

local function persist_buffer(bufnr)
	local state = M.state[bufnr]
	if not state then
		return
	end
	local entries = collect_buffer_entries(bufnr) or {}
	local store = load_store()
	if #entries == 0 then
		store[state.path] = nil
	else
		store[state.path] = entries
	end
	save_store(store)
end

-- ---------- float editor -----------------------------------------------------

local function open_editor(initial_text, on_save)
	local lines = vim.split(initial_text or "", "\n", { plain = true })
	local buf = api.nvim_create_buf(false, true)
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].filetype = "markdown"
	api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	local win = api.nvim_open_win(buf, true, {
		relative = "cursor",
		row = 1,
		col = 0,
		width = 60,
		height = 10,
		border = "rounded",
		style = "minimal",
		title = " Annotation (CR=save, q/Esc=cancel) ",
		title_pos = "center",
	})

	local closed = false
	local function close(save)
		if closed then
			return
		end
		closed = true
		local text
		if save then
			text = table.concat(api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
		end
		if api.nvim_win_is_valid(win) then
			api.nvim_win_close(win, true)
		end
		if save then
			on_save(text)
		end
	end

	local opts = { buffer = buf, nowait = true, silent = true }
	vim.keymap.set("n", "<CR>", function()
		close(true)
	end, opts)
	vim.keymap.set("n", "q", function()
		close(false)
	end, opts)
	vim.keymap.set("n", "<Esc>", function()
		close(false)
	end, opts)

	if initial_text == nil or initial_text == "" then
		vim.cmd("startinsert")
	end
end

-- ---------- CRUD -------------------------------------------------------------

local function ensure_state(bufnr)
	if not M.state[bufnr] then
		local path = buf_path(bufnr)
		if not path then
			return nil
		end
		M.state[bufnr] = { path = path, entries = {}, orphans = {}, visible = true }
	end
	return M.state[bufnr]
end

local function entry_at_cursor(bufnr)
	local state = M.state[bufnr]
	if not state then
		return nil
	end
	local row = api.nvim_win_get_cursor(0)[1] - 1
	local marks = api.nvim_buf_get_extmarks(bufnr, ns, { row, 0 }, { row, -1 }, {})
	for _, mark in ipairs(marks) do
		local id = mark[1]
		if state.entries[id] then
			return id, state.entries[id]
		end
	end
	return nil
end

function M.add()
	local bufnr = api.nvim_get_current_buf()
	local state = ensure_state(bufnr)
	if not state then
		vim.notify("Annotations require a real file buffer", vim.log.levels.WARN)
		return
	end
	if entry_at_cursor(bufnr) then
		M.edit()
		return
	end
	local row = api.nvim_win_get_cursor(0)[1] - 1
	open_editor("", function(text)
		if text == nil or text == "" then
			return
		end
		local line = api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
		local entry = {
			line = row + 1,
			hash = hash_line(line),
			snippet = trim(line),
			text = text,
			created = now_iso(),
			updated = now_iso(),
		}
		local id = render_entry(bufnr, entry)
		state.entries[id] = entry
		persist_buffer(bufnr)
	end)
end

function M.edit()
	local bufnr = api.nvim_get_current_buf()
	local state = ensure_state(bufnr)
	if not state then
		return
	end
	local id, entry = entry_at_cursor(bufnr)
	if not id or not entry then
		vim.notify("No annotation on this line", vim.log.levels.INFO)
		return
	end
	open_editor(entry.text, function(text)
		if text == nil then
			return
		end
		api.nvim_buf_del_extmark(bufnr, ns, id)
		state.entries[id] = nil
		if text == "" then
			persist_buffer(bufnr)
			return
		end
		entry.text = text
		entry.updated = now_iso()
		local new_id = render_entry(bufnr, entry)
		state.entries[new_id] = entry
		persist_buffer(bufnr)
	end)
end

function M.delete()
	local bufnr = api.nvim_get_current_buf()
	local state = M.state[bufnr]
	if not state then
		return
	end
	local id, entry = entry_at_cursor(bufnr)
	if not id or not entry then
		vim.notify("No annotation on this line", vim.log.levels.INFO)
		return
	end
	api.nvim_buf_del_extmark(bufnr, ns, id)
	state.entries[id] = nil
	persist_buffer(bufnr)
end

function M.toggle()
	local bufnr = api.nvim_get_current_buf()
	local state = M.state[bufnr]
	if not state then
		load_buffer(bufnr)
		return
	end
	if state.visible then
		clear_buffer(bufnr)
		state.visible = false
	else
		clear_buffer(bufnr)
		local refreshed = {}
		for _, entry in pairs(state.entries) do
			local id = render_entry(bufnr, entry)
			refreshed[id] = entry
		end
		state.entries = refreshed
		state.visible = true
	end
end

function M.reload()
	load_buffer(api.nvim_get_current_buf())
end

-- ---------- listing ----------------------------------------------------------

local function first_line(entry)
	return (vim.split(entry.text or "", "\n", { plain = true })[1]) or ""
end

function M.list_buffer()
	local bufnr = api.nvim_get_current_buf()
	local state = M.state[bufnr]
	if not state then
		vim.notify("No annotations loaded for this buffer", vim.log.levels.INFO)
		return
	end
	local items = {}
	for _, entry in pairs(state.entries) do
		table.insert(items, { filename = state.path, lnum = entry.line, text = first_line(entry) })
	end
	table.sort(items, function(a, b)
		return a.lnum < b.lnum
	end)
	if #items == 0 then
		vim.notify("No annotations in this file", vim.log.levels.INFO)
		return
	end
	fn.setqflist({}, " ", { title = "Annotations (this file)", items = items })
	vim.cmd("copen")
end

function M.list_all()
	local store = load_store()
	local items = {}
	for path, entries in pairs(store) do
		for _, entry in ipairs(entries) do
			table.insert(items, { filename = path, lnum = entry.line, text = first_line(entry) })
		end
	end
	if #items == 0 then
		vim.notify("No annotations stored", vim.log.levels.INFO)
		return
	end
	table.sort(items, function(a, b)
		if a.filename == b.filename then
			return a.lnum < b.lnum
		end
		return a.filename < b.filename
	end)
	fn.setqflist({}, " ", { title = "Annotations (all files)", items = items })
	vim.cmd("copen")
end

function M.list_orphans()
	local bufnr = api.nvim_get_current_buf()
	local state = M.state[bufnr]
	if not state or #state.orphans == 0 then
		vim.notify("No orphaned annotations for this buffer", vim.log.levels.INFO)
		return
	end
	local items = {}
	for _, entry in ipairs(state.orphans) do
		table.insert(items, {
			filename = state.path,
			lnum = entry.line,
			text = "[orphan] " .. (entry.snippet or "") .. " | " .. first_line(entry),
		})
	end
	fn.setqflist({}, " ", { title = "Orphaned annotations", items = items })
	vim.cmd("copen")
end

-- ---------- autocmds ---------------------------------------------------------

local group = api.nvim_create_augroup("KyotoAnnotations", { clear = true })

api.nvim_create_autocmd("BufReadPost", {
	group = group,
	pattern = "*",
	callback = function(args)
		load_buffer(args.buf)
	end,
})

api.nvim_create_autocmd("BufWritePost", {
	group = group,
	pattern = "*",
	callback = function(args)
		persist_buffer(args.buf)
	end,
})

api.nvim_create_autocmd("BufWipeout", {
	group = group,
	pattern = "*",
	callback = function(args)
		M.state[args.buf] = nil
	end,
})

-- ---------- keymaps ----------------------------------------------------------

local function bind(key, action, desc)
	vim.keymap.set("n", key, action, { desc = desc, silent = true })
end

bind("<leader>ma", M.add, "Annotation: add")
bind("<leader>me", M.edit, "Annotation: edit")
bind("<leader>md", M.delete, "Annotation: delete")
bind("<leader>mt", M.toggle, "Annotation: toggle visibility")
bind("<leader>ml", M.list_buffer, "Annotation: list (this file)")
bind("<leader>mL", M.list_all, "Annotation: list (all files)")
bind("<leader>mo", M.list_orphans, "Annotation: list orphans")

local wk_ok, wk = pcall(require, "which-key")
if wk_ok then
	wk.add({
		{ "<leader>m", group = "Memo", nowait = true, remap = false },
	})
end

-- ---------- user commands ----------------------------------------------------

api.nvim_create_user_command("KyotoAnnotationsToggle", M.toggle, {})
api.nvim_create_user_command("KyotoAnnotationsList", M.list_buffer, {})
api.nvim_create_user_command("KyotoAnnotationsListAll", M.list_all, {})
api.nvim_create_user_command("KyotoAnnotationsOrphans", M.list_orphans, {})
api.nvim_create_user_command("KyotoAnnotationsReload", M.reload, {})

return M
