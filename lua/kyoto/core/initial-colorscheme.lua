-- set colorscheme to nightfly with protected call
-- in case it isn't installed
local status, _ = pcall(vim.cmd, "colorscheme paragon")

if not status then
	print("Colorscheme not found!") -- print error if colorscheme not installed
	return
end




-----------




-- set colorscheme to nightfly with protected call
-- in case it isn't installed
-- local status, _ = pcall(vim.cmd, "colorscheme paragon")
pcall(vim.cmd, "set termguicolors")
local status, _ = pcall(vim.cmd, "colorscheme cyberpunk")
pcall(vim.cmd, "let g:airline_theme='cyberpunk'")
pcall(vim.cmd, "set cursorline")
pcall(vim.cmd, 'let g:cyberpunk_cursorline="black"')

if not status then
	print("Colorscheme not found!") -- print error if colorscheme not installed
	return
end
