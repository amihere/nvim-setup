local opt = vim.opt

vim.g.netrw_liststyle = 3

-- line numbers
opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- line wrapping
opt.wrap = false

-- search settings
opt.ignorecase = true
opt.smartcase = true

-- cursor line
opt.cursorline = true
opt.guicursor = ""

-- appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- backspace
opt.backspace = "indent,eol,start"

-- clipboard
opt.clipboard:append("unnamedplus")

-- split windows
opt.splitright = true
opt.splitbelow = true

-- the prime aegean
opt.incsearch = true
opt.hlsearch = false
opt.scrolloff = 8

-- TJ
opt.list = false
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Folds
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldtext = ""
opt.foldlevelstart = 1
opt.foldnestmax = 2
opt.fml = 3

opt.showmode = false
