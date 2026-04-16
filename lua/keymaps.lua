-- keymap.lua
vim.keymap.set({ 'n', 'x' }, 'zh', '%', { desc = 'porusza się pomiędzy początkiem i końcem nawiasów' })
-- wyłączenie Super-Alt-[r,p] / CMD-Option-[r,p]
vim.keymap.set({ 'n', 'i' }, '<M-D-r>', '<nop>')
vim.keymap.set({ 'n', 'i' }, '<M-D-p>', '<nop>')
vim.keymap.set({'n', 'x'}, '<m-j>', '<cmd>Gitsign next_hunk<cr>', { desc = 'następna zmiana' })
vim.keymap.set({'n', 'x'}, '<m-k>', '<cmd>Gitsign prev_hunk<cr>', { desc = 'poprzednia zmiana' })
vim.keymap.set('v', [[//]], [[y/\V<C-r>=escape(@",'/\')<CR><CR>]], {
    silent = true,
    desc = '// - wyszukuje zaznaczonego tekstu'
})
vim.keymap.set('n', '<leader>ts0', '<cmd>set scrolloff=0<cr>', { desc = 'Scrolloff 0' })
vim.keymap.set('n', '<leader>ts3', '<cmd>set scrolloff=3<cr>', { desc = 'Scrolloff 3' })
vim.keymap.set('n', '<leader>ts9', '<cmd>set scrolloff=999<cr>', { desc = 'Scrolloff 999' })
vim.keymap.set('n', '<leader>ts', function() vim.opt.spell = true; vim.opt.spelllang='pl' end, { desc = 'sprawdzanie pisownii' })
-- kiedy przeszukujemy historię komend, to możemy szybko zatwierdzić komendę za pomocą Ctrl-;
vim.keymap.set('c', '<c-;>', [[<cr>]])
vim.keymap.set('n', '<leader>s.', function()
    require('fzf-lua').oldfiles({
        winopts = {
            preview = { hidden = 'nohidden' },
            fullscreen = true,
        },
    })
end, { desc = 'ostatnio edytowane pliki' })
vim.keymap.set('v', [[<enter>]], 'ygv<esc>', { desc = 'Kopiuje zaznaczony tekst' })
-- vim.keymap.set('v', '<cr>', '"+y', { noremap = true, silent = true })
vim.keymap.set('n', 'yA', '<cmd>%yank<cr>', { desc = 'Kopiuje całą zawartość pliku do rejestru' })
vim.keymap.set('n', 'dA', '<cmd>%delete<cr>', { desc = 'Usuwa całą zawartość pliku' })
vim.keymap.set('n', [[dh]], 'xd0', { desc = 'Usuwa od kursora do początku linii' })
vim.keymap.set('n', [[dl]], 'd$', { desc = 'Usuwa od kursora do końca linii' })
vim.keymap.set({ 'n', 'x' }, '<leader>y', '"+y', { desc = 'kopiuje do rejestru "+"' })
vim.keymap.set({ 'n', 'x' }, '<leader>p', '"+p')
vim.keymap.set({ 'n', 'x' }, '<leader>P', '"+P')
vim.keymap.set('n', '<leader>tg', [[<cmd>lua require('functions').live_grep()<cr>]], { desc = 'Live Grep' })
vim.keymap.set('n', '<leader>th', '<cmd>FzfLua helptags<cr>', { desc = 'Pomoc' })
vim.keymap.set("n", "<leader>e", require("oil").open, { desc = "Menadżer plików Oil" })
vim.keymap.set('n', '<leader>f', [[<cmd>lua require('functions').fzf_files()<cr>]], { desc = 'FZF Files' })
vim.keymap.set('n', '<leader>if', [[<cmd>lua require('functions').file_info()<cr>]], { desc = 'FileInfo'})
vim.keymap.set("n", [[<leader>n]], function() vim.cmd[[Neotree reveal_force_cwd toggle]] end, { desc = "Neotree" })
-- Otwiera Neotree podążając za linkiem symbolicznym
vim.keymap.set("n", [[<leader>N]], function()
    local file_path = vim.api.nvim_buf_get_name(0)
    if file_path ~= "" then
        local resolved_path = vim.fn.resolve(file_path)
        local dir_path = vim.fn.fnamemodify(resolved_path, ":h")
        vim.cmd("Neotree dir=" .. dir_path .. " toggle")
    else
        print("Brak pliku w bieżącym buforze")
    end
end, { desc = 'Neotree (resolve symlink)' })
vim.keymap.set('n', '<leader>tn', '<cmd>enew<cr>', { desc = 'nowy bufor' })
vim.keymap.set('n', '<leader>tf', [[<cmd>lua require('functions').f_terminal()<cr>]], { desc = 'terminal'})
vim.keymap.set("n", "<leader>tT", [[<cmd>lua require('.functions').t_term()<cr>]], { desc = 'terminal'})
vim.keymap.set("n", "<leader>tt", [[<cmd>lua require('.functions').terminal()<cr>]], { desc = 'terminal'})
vim.keymap.set({ 'n', 'i' }, '<esc>', '<cmd>nohl<cr><cmd>NoiceDismiss<cr><esc>', { silent = true, desc = "wyłącza wyróżnianie szukanego tekstu" })
-- vim.keymap.set('i', 'kj', '<cmd>nohl<cr><cmd>NoiceDismiss<cr><esc>', { silent = true, desc = "wyłącza wyróżnianie szukanego tekstu" })
vim.keymap.set('n', [[']], '<cmd>FzfLua marks<cr>', { desc = 'marks' })
vim.keymap.set('n', [["]], '<cmd>FzfLua registers<cr>', { desc = 'rejestry' })
vim.keymap.set('n', '<leader>w', [[<cmd>lua require('functions').write_file()<cr>]], { desc = 'zapisuje plik' })
vim.keymap.set('n', '<bs>', [[<cmd>lua require('functions').write_file()<cr>]])
vim.keymap.set("n", [[<leader>q]], function()
    require('functions').write_file()
    vim.cmd[[q]]
end, { desc = "Zapisuje zmiany i wychodzi" })
vim.keymap.set('n', '<localleader>r', '<cmd>restart<cr>', { desc = 'restart NVim' })
vim.keymap.set('n', '<localleader>w', '<cmd>set wrap!<cr>', { desc = 'toggle wrap' })
vim.keymap.set('n', '<localleader><localleader>', 'ciw', { desc = 'ciw' })
vim.keymap.set('n', '<localleader>c', 'ciw', { desc = 'ciw' })
vim.keymap.set('n', '<localleader>d', 'diw', { desc = 'diw' })
vim.keymap.set('n', '<localleader>y', 'yiw', { desc = 'yiw' })
vim.keymap.set('n', [[<leader>v]], [[<cmd>lua require('functions').config_files()<cr>]], { desc = 'nvim configs' })
vim.keymap.set('n', 'U', '<c-r>', { desc = 'redo' })
-- zamiana zn / zm
vim.keymap.set('n', 'qq', '<cmd>qa<cr>', { desc = 'wychodzi z nvim' })
vim.keymap.set("n", [[<s-enter>]], "mzO<esc>`z", { desc = "dodaje pustą linię powyżej bieżącej" })
vim.keymap.set("n", [[<enter>]], "mzo<esc>`z", { desc = "dodaje pustą linię poniżej bieżącej" })
vim.keymap.set({ 'n', 'v' }, 'gh', '0', { desc = "początek linii" })  -- ^
vim.keymap.set({ 'n', 'v' }, 'gl', '$', { desc = "koniec linii" })    -- g_
vim.keymap.set('n', '<tab>', '<C-^>', { desc = 'przełączanie się pomiędzy dwoma ostatnimi buforami' })
vim.keymap.set("n", [[<s-tab>]], "<cmd>FzfLua buffers winopts.fullscreen=true<cr>", { desc = "pozwala wybrać bufor zlisty" })
vim.keymap.set("n", [[<leader>b]], "<cmd>Neotree source=buffers reveal_force_cwd=true position=right action=focus toggle<cr>", { desc = "NeoTree otwarte bufory" })
vim.keymap.set('n', 'H', '<cmd>bprevious<cr>', { desc = 'poprzedni bufor' })
vim.keymap.set('n', 'L', '<cmd>bnext<cr>', { desc = 'następny bufor' })
vim.keymap.set('n', [[<leader>d]], '<cmd>bdelete<cr>', { desc = 'usuwa bufor' })
vim.keymap.set('n', [[<leader>cc]], '<cmd>close<cr>', { desc = 'zamyka okno' })
vim.keymap.set("n", [[<leader>o]], "<cmd>only<cr>", { desc = 'pozostawia otwarte tylko aktywne okno' })
vim.keymap.set({ 'n', 'v' }, ';', ':', { desc = 'tryb Command' })
-- okna
vim.keymap.set('n', [[<c-h>]], [[<c-w><c-h>]], { desc = 'przechodzi do okna po lewej' })
vim.keymap.set('n', [[<c-l>]], [[<c-w><c-l>]], { desc = 'przechodzi do okna po prawej' })
vim.keymap.set('n', [[<c-j>]], [[<c-w><c-j>]], { desc = 'przechodzi do okna niżej' })
vim.keymap.set('n', [[<c-k>]], [[<c-w><c-k>]], { desc = 'przechodzi do okna wyżej' })
-- zmiana wielkości okna <shift-alt-h,j,k,l>
vim.keymap.set('n', '<s-m-h>', '<cmd>vertical resize -2<cr>')
vim.keymap.set('n', '<s-m-j>', '<cmd>resize +2<cr>')
vim.keymap.set('n', '<s-m-k>', '<cmd>resize -2<cr>')
vim.keymap.set('n', '<s-m-l>', '<cmd>vertical resize +2<cr>')
vim.keymap.set('n', '<leader>sv', function()
    local alt_buf = vim.fn.bufnr('#')
    if alt_buf ~= -1 and vim.fn.buflisted(alt_buf) == 1 then
        vim.cmd('vsplit #')
    else
        vim.cmd('vsplit')
    end
end, { silent = true, desc = 'dzieli okno w pionie' })
vim.keymap.set('n', '<leader>sp', function()
    local alt_buf = vim.fn.bufnr('#')
    if alt_buf ~= -1 and vim.fn.buflisted(alt_buf) == 1 then
        vim.cmd('split #')
    else
        vim.cmd('split')
    end
end, { silent = true, desc = 'dzieli okno w poziomie' })
-- plugin flash.nvim wyszukiwanie za pomocą "s"
vim.keymap.set({ "n", "o", "x" }, "s", function()
    require("flash").jump({
        search = {
            -- forward = true,
            wrap = true,
            multi_window = false,
            mode = function(str)
                if str == " " then
                    return str
                end
                -- wyszukuje tylko poczƒÖtku wyrazu
                return "\\<" .. str
            end,
        },
    })
end)
-- plugin flash.nvim Remote Flash
vim.keymap.set("o", "R", function()
    require("flash").remote()
end)
vim.keymap.set({'o', 'n', 'x'}, 'S', function()
    require('flash').treesitter()
end)
-- Insert
local auto_complete = require('functions').auto_complete()
vim.keymap.set('i', '<c-Space>', auto_complete, { expr = true, desc = 'autouzupełnianie z bufora' })
vim.keymap.set('i', '<cr>', function()
    return vim.fn.pumvisible() == 1 and '<c-y>' or '<cr>'
end, { expr = true, desc = 'potwierdź lub nowa linia' })
-- poruszanie się w trybie COMMAND
vim.keymap.set('c', '<c-j>', '<down>')
vim.keymap.set('c', '<c-k>', '<up>')
vim.keymap.set('c', '<c-h>', '<left>')
vim.keymap.set('c', '<c-l>', '<right>')
--
vim.keymap.set("c", "<c-p>", [[<c-r>"]], { desc = "Wkleja w linii komend"})
-- terminal
vim.keymap.set('t', [[<c-h>]], [[<c-\><c-n><c-w>h]])
vim.keymap.set('t', [[<c-j>]], [[<c-\><c-n><c-w>j]])
vim.keymap.set('t', [[<c-k>]], [[<c-\><c-n><c-w>k]])
vim.keymap.set('t', [[<c-l>]], [[<c-\><c-n><c-w>l]])
--  QuickFix
vim.keymap.set('n', [[<c-q>]], [[<cmd>copen<cr>]], { desc = 'Otwiera listę quickfix' })
vim.keymap.set('n', ']q', vim.cmd.cnext, { desc = 'Przechodzi do następnego elementu na liście quickfix' })
vim.keymap.set('n', '[q', vim.cmd.cprev, { desc = 'Przechodzi do poprzedniego elementu na liście quickfix' })
-- Bookmarks
vim.keymap.set("n", "<leader>cdd", function()
    require("functions").CD()
end, { desc = "Przechodzi do wybranego katalogu z pliku bmfiles" })
vim.keymap.set("n", "<leader>cde", function()
    require("functions").CDE()
end, { desc = "Przechodzi do wybranego katalogu z pliku bmfiles i otwiera katalog w menadżerze plików" })
vim.keymap.set("n", "<leader>cds", function()
    require("functions").CDS()
end, { desc = "Otwiera wyszukiwanie fzf-lua.files w wybranym katalogu z bmdirs" })
-- marks
-- vim.keymap.set('n', 'mm', 'mm', { desc = 'ustawia znacznik m' })
-- vim.keymap.set('n', 'M', '`m', { desc = 'przejście do znacznika m' })
local bm = require "bookmarks"
vim.keymap.set("n","mm",bm.bookmark_toggle)     -- add or remove bookmark at current line
vim.keymap.set("n","mi",bm.bookmark_ann)        -- add or edit mark annotation at current line
vim.keymap.set("n","mc",bm.bookmark_clean)      -- clean all marks in local buffer
vim.keymap.set("n","mn",bm.bookmark_next)       -- jump to next mark in local buffer
vim.keymap.set("n","mp",bm.bookmark_prev)       -- jump to previous mark in local buffer
vim.keymap.set("n","ml",bm.bookmark_list)       -- show marked file list in quickfix window
vim.keymap.set("n","mx",bm.bookmark_clear_all)  -- removes all bookmarks
vim.keymap.set("n", "vv", "^vg_", { desc = "Zaznacza linię pomijając puste znaki na początku i znak końca linii" })
vim.keymap.set('n', '<leader>u', function()
    vim.cmd.packadd[[nvim.undotree]]
    require('undotree').open()
end, { desc = 'UndoTree' })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = 'przenosi zaznaczenie w dół' })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = 'przenosi zaznaczenie w górę' })
vim.keymap.set("n", "<leader>s.", function()
    require('fzf-lua').oldfiles({
        winopts = {
            preview = { hidden = "nohidden" },
            fullscreen = true,
        },
    })
end, { desc = "Ostatnio edytowane pliki" })
-- tworzy nowy punkt undo po wprowadzeniu jednego ze znaków { " ", ".", ",", "!", "?" }
for _, key in ipairs({ " ", ".", ",", "!", "?" }) do
    vim.keymap.set("i", key, key .. "<c-g>u", { silent = true })
end
-- Standardowe skróty klawiszowe
vim.keymap.set('n', 'ge', 'ge', { desc = 'koniec poprzedniego wyrazu' })
vim.keymap.set({ 'n', 'x' }, '<c-d>', '<c-d>zz')
vim.keymap.set({ 'n', 'x' }, '<c-u>', '<c-u>zz')
vim.keymap.set("n", [[gf]], [[<cmd>edit <cfile><cr>]], { desc = "otwiera plik pod kursorem" })
vim.keymap.set('n', 'j', [[v:count == 0 ? 'gj' : 'j']], { expr = true })
vim.keymap.set('n', 'k', [[v:count == 0 ? 'gk' : 'k']], { expr = true })
vim.keymap.set("n", "zn", "zm", { noremap = true })
vim.keymap.set("n", "zm", "zn", { noremap = true })
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "J", "mzJ`z", { desc = "pozostawia kursor po łączeniu linii" })
vim.keymap.set({ 'n', 'x' }, 'gg', 'gg', { desc = 'początek pliku' })
vim.keymap.set({ 'n', 'x' }, 'go', 'go', { desc = 'początek pliku' })
vim.keymap.set({ 'n', 'x' }, 'G', 'G', { desc = 'koniec pliku' })
