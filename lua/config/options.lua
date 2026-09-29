-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.relativenumber = false
vim.g.autoformat = false

-- The IDE's universal key is `,` (not Space): reachable without leaving the
-- home row while typing. Every LazyVim `<space>` binding becomes `,`-prefixed,
-- e.g. `<space>ff` -> `,ff`. (Note: vim's `,` reverse-of-`;` repeat is gone.)
vim.g.mapleader = ","
