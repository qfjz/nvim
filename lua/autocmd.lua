-- autocmd.lua

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local api = vim.api

-- wyłącza parametry `cro`, nie wstawia automatycznie komentarza w kolejnej linii
vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
    pattern = "*",
    desc = "Wyłącza auto-komentarzenie (cro) i sprawdza zmiany na dysku",
    callback = function()
        vim.cmd[[setlocal formatoptions-=cro]]
        vim.cmd[[checktime]]
    end,
})

autocmd({ "RecordingLeave", }, {
    group = augroup("NotifyMacroStop", { clear = true }),
    desc = "Powiadomienie po zakończeniu nagrywania makro",
    callback = function()
        local msg = "Zakończyłem nagrywać makro " .. "[" .. vim.fn.reg_recording() .. "]"
        vim.notify(msg, "info", {
            timeout = 6000,
        })
    end,
})

autocmd("FileType", {
    pattern = { 'oil', 'nvim-undotree' },
    desc = "Wyłącza numerację i znaki w pasku dla okien oil/undotree",
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
    end,
})

autocmd('TermOpen', {
    group = augroup('startinsert', { clear = true }),
    desc = "Wejdź w tryb insert po otwarciu terminalu",
    callback = function()
        vim.cmd.startinsert()
    end,
})

-- zapisanie pozycji kursora
autocmd('BufReadPost', {
    group = augroup('restore_cursor', { clear = true }),
    desc = 'Przywróć pozycję kursora',
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Pomijanie buforów wirtualnych (Oil, fugitive, help, terminal, itp.)
local function is_real_file()
    return vim.bo.buftype == "" and vim.fn.expand("%:p") ~= ""
end

-- Automatycznie przeładowuje bufor jeśli zostanie zmodyfikowany
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    callback = function()
        if not is_real_file() or vim.fn.mode() == "c" then return end
        vim.cmd[[checktime]]
    end
})

autocmd('FileChangedShellPost', {
    group = augroup('file_check_notify', { clear = true }),
    pattern = '*',
    desc = 'Odświeżono plik po zmianie na dysku',
    callback = function(event)
        local bufname = vim.fn.fnamemodify(vim.fn.bufname(event.buf), ':~:.')
        vim.notify('Plik zmieniony na dysku: ' .. bufname, vim.log.levels.INFO, {
            title = 'Uwaga',
        })
    end,
})

-- Jeśli bufor jest pusty można go zamknąć za pmocą klawisza 'q'
autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        -- Sprawdzamy, czy bufor jest pusty i niezmodyfikowany
        if api.nvim_buf_line_count(0) == 1 and
            api.nvim_buf_get_lines(0, 0, 1, false)[1] == "" and
            not vim.bo.modified then
            -- Sprawdzamy, czy to ostatni bufor
            local bufs = api.nvim_list_bufs()
            local loaded_bufs = 0
            for _, buf in ipairs(bufs) do
                if api.nvim_buf_is_loaded(buf) and vim.fn.getbufvar(buf, "buflisted") then
                    loaded_bufs = loaded_bufs + 1
                end
            end
            -- Jeśli jest tylko jeden załadowany i wymieniony bufor, mapuj q na :qa
            if loaded_bufs == 1 then
                vim.keymap.set('n', 'q', '<cmd>qa<cr>', { buffer = true, silent = true, nowait = true })
            else
                -- W przeciwnym razie mapuj q na :bd
                vim.keymap.set('n', 'q', '<cmd>bd<cr>', { buffer = true, silent = true, nowait = true })
            end
        end
    end,
})

autocmd('FileType', {
    group = augroup('close_with_q', { clear = true }),
    desc = "Ukrywa buflisted i mapuje q na bd dla scratch/help/qf/undotree",
    pattern = {
        'scratch',
        'help',
        'qf',
        'nvim-undotree'
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set('n', 'q', '<cmd>bd!<cr>', { nowait = true, buffer = event.buf, silent = true })
    end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Wyróżnia skopiowany tekst',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch",  -- :h highlight-groups
            timeout = 100,
        })
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("vertical_help", { clear = true }),
    desc = "Vertial Help",
    pattern = {
        "help",
    },
    callback = function()
        vim.bo.bufhidden = "unload"
        vim.cmd.wincmd("L")
        vim.cmd.wincmd("=")
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("help_shortcuts", { clear = true }),
    desc = "Help Shortcuts",
    pattern = {
        "help",
    },
    callback = function(args)
        vim.keymap.set("n", "d", "<c-d>", { nowait = true, buffer = args.buf })
        vim.keymap.set("n", "u", "<c-u>", { nowait = true, buffer = args.buf })
        vim.api.nvim_buf_set_keymap(0, "n", "<leader>l", "<c-]>", { noremap = true })
        vim.api.nvim_buf_set_keymap(0, "n", "<leader>h", "<c-t>", { noremap = true })
    end,
})

-- Kolory dla rednder-markdown
vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("heading_colors", {}),
    pattern = {
        "*.md",
    },
    callback = function()
        local color_bg = 'Normal'
        -- local color_fg = '#1e1832'
        local color1_fg = '#ffffff'
        local color2_fg = '#37f499'
        local color3_fg = '#04d1f9'
        local color4_fg = '#987afb'
        local color5_fg = '#19dfcf'
        local color6_fg = '#1682ef'
        vim.cmd(string.format([[highlight RenderMarkdownH1Bg cterm=bold gui=bold guibg=%s guifg=%s]], color_bg, color1_fg))
        vim.cmd(string.format([[highlight RenderMarkdownH2Bg cterm=bold gui=bold guibg=%s guifg=%s]], color_bg, color2_fg))
        vim.cmd(string.format([[highlight RenderMarkdownH3Bg cterm=bold gui=bold guibg=%s guifg=%s]], color_bg, color3_fg))
        vim.cmd(string.format([[highlight RenderMarkdownH4Bg cterm=bold gui=bold guibg=%s guifg=%s]], color_bg, color4_fg))
        vim.cmd(string.format([[highlight RenderMarkdownH5Bg cterm=bold gui=bold guibg=%s guifg=%s]], color_bg, color5_fg))
        vim.cmd(string.format([[highlight RenderMarkdownH6Bg cterm=bold gui=bold guibg=%s guifg=%s]], color_bg, color6_fg))
        vim.cmd(string.format([[highlight Folded cterm=bold gui=bold guibg=%s guifg=%s]], color_bg, color1_fg))
    end,
})

-- folds
vim.api.nvim_create_autocmd("BufUnload", {
    group = vim.api.nvim_create_augroup("user_cmds", { clear = true }),
    pattern = "*.*,*file*",
    desc = "save view (folds), when closing file",
    callback = function()
        vim.opt_local.viewoptions = "folds"
        vim.cmd[[mkview]]
    end,
})

vim.api.nvim_create_autocmd("FileReadPre", {
    group = vim.api.nvim_create_augroup("user_cmds", { clear = true }),
    pattern = "*.*,*file*",
    desc = "load view (folds), when opening file",
    command = "silent! loadview",
})
