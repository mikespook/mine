-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- UNDO TREE
vim.opt.swapfile = false -- creates a swapfile
vim.opt.backup = false -- creates a backup file
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = false -- enable persistent undo
-- END UNDO TRREE

vim.o.foldmethod = "indent" -- Set 'indent' folding method
vim.o.foldlevel = 2 -- Display all folds except top ones
vim.o.foldnestmax = 10 -- Create folds only for some number of nested levels

vim.g.mapleader = ","
vim.g.maplocalleader = ","
vim.opt.timeoutlen = 1000

vim.opt.wrap = false
vim.opt.expandtab = true
vim.opt.scrolloff = 999
vim.opt.virtualedit = "block"
vim.opt.inccommand = "split" -- creat a split buffer for substitute command (search/replace)

vim.cmd("set noexpandtab")
vim.cmd("set tabstop=4")
vim.cmd("set shiftwidth=4")

-- Navigate vim panes better
vim.keymap.set("n", "<c-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")

vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>")
vim.wo.number = true
