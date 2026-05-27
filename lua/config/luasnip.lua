require("luasnip").config.setup({
    history = true,              -- Zapamiętuj historię snippetów
    updateevents = "TextChanged,TextChangedI", -- Aktualizuj przy zmianie tekstu
    enable_autosnippets = true, -- Włącz automatyczne snippety (opcjonalnie)
    ext_opts = {
        [require("luasnip.util.types").insertNode] = {
            unvisited = {
                -- Opcja 1: Wirtualny tekst
                virt_text = { { "⤚", "WarningMsg" } },
                virt_text_pos = "inline",
                -- Opcja 2: Podświetlenie tła (działa tylko jeśli pozycja ma tekst)
                hl_group = "Visual",  -- lub "IncSearch" dla mocniejszego efektu
            },
            visited = {
                hl_group = "Comment",
            },
        },
        [require("luasnip.util.types").exitNode] = {
            unvisited = {
                virt_text = { { "◼", "Identifier" } },
                virt_text_pos = "inline",
            },
        },
        [require("luasnip.util.types").choiceNode] = {
            active = {
                virt_text = { { "▼", "Special" } },
                virt_text_pos = "inline",
            },
        },
    },
})
-- Załaduj snippety z friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()
-- (OPCJONALNIE) Załaduj własne snippety z ~/.config/nvim/snippets
local snippets_path = vim.fn.stdpath("config") .. "/snippets"
if vim.fn.isdirectory(snippets_path) == 1 then
    require("luasnip.loaders.from_vscode").lazy_load({ paths = { snippets_path } })
end
