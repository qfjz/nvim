require("luasnip").config.setup({
    history = true,              -- Zapamiętuj historię snippetów
    updateevents = "TextChanged,TextChangedI", -- Aktualizuj przy zmianie tekstu
    enable_autosnippets = true, -- Włącz automatyczne snippety (opcjonalnie)
})
-- Załaduj snippety z friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()
-- (OPCJONALNIE) Załaduj własne snippety z ~/.config/nvim/snippets
local snippets_path = vim.fn.stdpath("config") .. "/snippets"
if vim.fn.isdirectory(snippets_path) == 1 then
    require("luasnip.loaders.from_vscode").lazy_load({ paths = { snippets_path } })
end
