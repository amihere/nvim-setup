-- import nvim-cmp plugin safely
local cmp_status, cmp = pcall(require, "cmp")
if not cmp_status then
	return
end

-- import luasnip plugin safely
local luasnip_status, ls = pcall(require, "luasnip")
if not luasnip_status then
	return
end

-- load vs-code like snippets from plugins (e.g. friendly- snippets)
require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./xtra_snippets" } })

vim.opt.completeopt = "menu,menuone,noselect"

cmp.setup({
	experimental = {
		native_menu = false,
		ghost_text = true,
	},
	snippet = {
		expand = function(args)
			ls.lsp_expand(args.body)
		end,
	},
	completion = {
		autocomplete = false,
		keyword_length = 3,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
		["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
		["<C-e>"] = cmp.mapping.abort(), -- close completion window
		["<C-c>"] = cmp.mapping.abort(), -- close completion window
		["<CR>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				if ls.expandable() then
					ls.expand()
				else
					cmp.confirm({
						select = false,
					})
				end
			else
				fallback()
			end
		end),

		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif ls.locally_jumpable(1) then
				ls.jump(1)
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif ls.locally_jumpable(-1) then
				ls.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),

	-- sources for autocompletion
	sources = cmp.config.sources({
		{ name = "luasnip" }, -- snippets
		{ name = "nvim_lsp" }, -- lsp
		{ name = "buffer", keyword_length = 5 }, -- text within current buffer
		{ name = "path", keyword_length = 5 }, -- file system paths
	}),
})
