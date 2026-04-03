map = vim.keymap.set
map('n', '<leader>w', [[<cmd>lua require('functions').write_file()<cr>]], { desc = 'zapisuje plik' })
map('n', '<localleader>r', '<cmd>restart<cr>', { desc = 'restart NVim' })
map('n', [[<leader>v]], [[<cmd>lua require('functions').config_files()<cr>]])
-- zamiana zn / zm
vim.keymap.set("n", "zn", "zm", { noremap = true })
vim.keymap.set("n", "zm", "zn", { noremap = true })
-- tworzy nowy punkt undo po wprowadzeniu jednego ze znaków { " ", ".", ",", "!", "?" }
for _, key in ipairs({ " ", ".", ",", "!", "?" }) do
    map("i", key, key .. "<c-g>u", { silent = true })
end
