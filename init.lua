-- qfjz/nvim

-- Ustawienie języka Neovim
vim.cmd[[silent! language en_US.utf-8]]

-- Ustawienie klawisza Leader
vim.g.mapleader = " "
vim.g.maplocalleader = ","

require('options')
require('pack-plugins')
require('catppuccin-gruvbox')
require('keymaps')

require('oil').setup()

vim.cmd.colorscheme[[catppuccin-mocha]]
