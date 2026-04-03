-- restart Neovim
vim.keymap.set('n', '<localleader>r', '<cmd>restart<cr>', { desc = 'restart NVim' })
-- tworzy nowy punkt undo po wprowadzeniu jednego ze znaków { " ", ".", ",", "!", "?" }
for _, key in ipairs({ " ", ".", ",", "!", "?" }) do
    vim.keymap.set("i", key, key .. "<c-g>u", { silent = true })
end
