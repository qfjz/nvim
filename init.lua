-- qfjz/nvim

-- Ustawienie języka Neovim
vim.cmd[[silent! language en_US.utf-8]]

-- Ustawienie klawisza Leader
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- config.WinBar
vim.g.projects_dir = vim.env.HOME .. '/workspace/git'
vim.g.personal_projects_dir = vim.g.projects_dir .. 'qfjz'
vim.g.work_projects_dir = vim.env.HOME .. '/workspace/git/work'

require('options')
require('pack-plugins')
require('catppuccin-gruvbox')
require('keymaps')
require('functions')
require('winbar')

require('config.oil')
require('config.noice')
require('config.flash')
require('config.gitsigns')
require('config.blink')

require('toggleterm').setup()

vim.cmd.colorscheme[[catppuccin-mocha]]
