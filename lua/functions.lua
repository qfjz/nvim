local M = {}

local config_dir = vim.fn.stdpath("config")

local BmDirs = os.getenv("BM_DIRS")     -- plik z ulubionymi katalogami ($HOME/.config/bmdirs)
local BmFiles = os.getenv("BM_FILES")   -- plik z ulubionymi plikami ($HOME/.config/bmfiles)
local SPDirENV = os.getenv("SPDir")     -- katalog z tymczasowymi notatkami ($HOME/Notes/SP)
local OBS_SP = os.getenv("OBS_SP")      -- katalog z tymczasowymi notatkami w Obsidian.md ($HOME/Obsidian/SP)
local Notes_Dir = os.getenv("NOTES_DIR")
local QFJZ_Notes_Dir = os.getenv('QFJZ_Notes_Dir')

-- Funkcje
--
-- config_files() - pliki konfiguracyjne Neovim
-- write_file()
-- cdfd() przechodzi do katalogu w którym znajduje się edytowany plik, potrafi podążać za linkami symbolicznymi
-- f_terminal(cmd) floating terminal
-- terminal()
-- cd_git_root() - przechodzi do głównego katalogu repozytorium Git
-- terminal_git() - otwiera termina w głównym katalogu repozytorium Git
-- t_term() otwiera terminal podążając za linkiem symbolicznym otwartego pliku
-- live_grep()
-- fzf_files()
-- neotree_symlink()
-- create_floating_scratch(content)
-- CD()
-- CDE() - otwiera menadżer plików w wybranej lokalizacji
-- CDS() - otwiera wyszukiwanie fzf-lua.files w wybranym katalogu z bmdirs
-- EditCDDirs() - edycja pliku BmDirs
-- AddCDDir() - dodaje bieżący katalog do pliku bmdirs
-- AddBmFile() - dodaje edytowany plik do bmfiles
-- BmFiles() - pokazuje okno wyboru ulubionych plików
-- EditBmFiles() - edycja pliku bmfiles
-- scratchpad(raw_args)
-- new_scratchpad() - pozwala wybrać nazwę tymczasowej notatki
-- select_scratchpad()
-- last_scratchpad()
-- obsidian_scratchpad() - otwiera wybrany plik Scratchpad*.md jako normalny bufor
-- kolory()
-- komendy()
-- new_task(filepath)
-- choose_tasks_file()
-- notes_files()
-- fzf_md_files(dir, mode) - przeszukiwanie plików Markdown w podanym katalogu
-- get_latest_modified_file(dir)
-- set_transparent()
-- gd() tworzy katalog o nazwie wyrazu pod kursorem, jeśli chcesz utworzyć podkatalog pamiętaj żeby dodać '/' na końcu
-- copy_filename()
-- keymaps(category_name)

-- Funkcje pomocnicze
--
-- input_filename()
-- trim()
-- mk_dir()
-- auto_complete()
-- get_current_colorscheme() - pobiera obecny schemat kolorystyczny

function M.config_files()
    -- local rg_cmd = "rg --files --follow -g '!plugin/' -g '*.lua'"
    local rg_cmd = "fd -I -t f -H -g '*.lua' | xargs eza --sort=modified --reverse"
    local cwd_dir = config_dir
    local prompt = " NvimConfig > "
    require"fzf-lua".files({
        prompt = prompt,
        cwd = cwd_dir,
        cmd = rg_cmd,
        winopts = {
            preview = { hidden = "nohidden" },
            title = " Neovim Config ",
            fullscreen = true,
        }
    })
end

-- funkcja wyświetla okno do wprowadzenia nazwy pliku do zapisania
function M.input_filename()
    vim.ui.input({ prompt = "Podaj nazwę pliku", default = vim.fn.expand("%:p:h") .. "/" },
    function(input)
        if not input then
            return
        end
        if M.trim(input) == "" then
            return vim.notify("Podaj nazwę pliku")
        end
        local dir = vim.fs.dirname(input)
        if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, "p")
            vim.notify("Utworzyłem katalog" .. " " .. dir)
        end
        if vim.fn.isdirectory(input) == 1 then
            vim.notify("Podaj nazwę pliku")
            return
        end
        vim.cmd("silent write" .. input)
        vim.notify("Utworzyłem" .. " " .. vim.fn.expand("%:p"))
        M.cdfd()
        -- vim.cmd("cd " .. dir)
    end)
end

-- zapisuje plik write_file()
function M.write_file()
    local bt = vim.bo.buftype
    local ft = vim.bo.filetype
    local ignore_buftype = {
        nofile = true,
        prompt = true,
        terminal = true,
    }
    local ignore_filetype = {
        ["neo-tree"] = true,
        git = true,
        gitcommit = true,
    }
    if ignore_buftype[bt] or ignore_filetype[ft] then
        vim.notify("Pomijam zapis dla bufora typu: " .. ft .. " (" .. bt .. ")")
        return
    end
    for _, v in ipairs(vim.fn.getbufinfo("%")) do
        if v.name == "" then
            vim.notify("Bufor bez nazwy, plik nie zostanie zapisany.")
            M.input_filename()
            return
        end
    end
    if vim.fn.filereadable(vim.fn.expand("%")) == 1 then
        vim.cmd("lcd %:p:h")
        for _, v in ipairs(vim.fn.getbufinfo("%")) do
            if v.changed == 1 then
                vim.cmd("silent update")
                vim.notify("Zapisałem" .. " " .. vim.fn.expand("%:p"))
            else
                vim.notify("Brak zmian w pliku" .. " " .. vim.fn.expand("%:p"))
            end
        end
    else
        M.mk_dir()
        vim.cmd("silent write")
        vim.notify("Utworzyłem" .. " " .. vim.fn.expand("%:p"))
    end
end

function M.trim(str)
    return str:gsub("^%s+", ""):gsub("%s+$", "")
end

-- funkcja przechodzi do katalogu w którym znajduje się edytowany plik, potrafi podążać za linkami symbolicznymi
function M.cdfd(print)
    local filename = vim.uv.fs_realpath(vim.api.nvim_buf_get_name(0))
    local directory = vim.fs.dirname(filename)
    if directory == nil then
        vim.notify("Plik nie ma swojego miejsca na dysku", 4, { timeout = 6000 })
        return
    end
    local pwd_dir = vim.fn.system[[pwd]]
    local pwd_dir_trim = vim.trim(pwd_dir)
    if pwd_dir_trim == directory then
        local pwd = vim.fn.system[[pwd]]
        if print == nil then
            vim.notify(pwd, 2, { timeout = 6000 })
        end
        return
    else
        vim.cmd("cd " .. directory)
        if print == nil then
            vim.notify(directory, 2, { timeout = 6000 })
        end
    end
end

-- tworzy katalog
function M.mk_dir()
    local dir = vim.fn.expand("%:p:h")
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
    end
end

-- floating terminal
function M.f_terminal(cmd)
    local max_height = vim.api.nvim_win_get_height(0)
    local max_width = vim.api.nvim_win_get_width(0)
    local height = math.floor(max_height * 0.8)
    local width = math.floor(max_width * 0.8)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        height = height,
        width = width,
        col = (max_width - width) / 2,
        row = (max_height - height) / 2,
        style = 'minimal',
        border = 'rounded',
    })
    vim.cmd.term(cmd or nil)
    vim.cmd('startinsert')
end

function M.terminal()
    M.cdfd()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd("J")
    vim.cmd('startinsert')
    vim.api.nvim_win_set_height(0, 9)
end

function M.cd_git_root()
    M.cdfd('ziuta')  -- przechodzi do katalogu w którym znajduje się otwarty plik
    local result = vim.fn.system("git rev-parse --is-inside-work-tree")
    local root_dir
    if vim.v.shell_error == 0 and result:find("true") then
        root_dir = vim.fn.system("git rev-parse --show-toplevel")
        vim.cmd("cd " .. root_dir)
        return root_dir
    end
end

function M.terminal_git()
    M.cd_git_root()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd("J")
    vim.cmd('startinsert')
    vim.api.nvim_win_set_height(0, 9)
end

-- otwiera terminal podążając za linkiem symbolicznym otwartego pliku
function M.t_term()
    local file_path = vim.api.nvim_buf_get_name(0)
    if file_path ~= "" then
        local resolved_path = vim.fn.resolve(file_path)
        local dir_path = vim.fn.fnamemodify(resolved_path, ":h")
        vim.cmd("ToggleTerm dir=" .. dir_path)
    else
        print("brak pliku w bieżącym buforze")
    end
end

-- funkcja do wywoływania autouzupełniania
function M.auto_complete()
    if vim.fn.pumvisible() == 1 then
        return vim.api.nvim_replace_termcodes('<C-n>', true, false, true)
    elseif vim.fn.match(vim.fn.getline('.'), '\\w\\+$') >= 0 then
        return vim.api.nvim_replace_termcodes('<C-x><C-n>', true, false, true)
    else
        return vim.api.nvim_replace_termcodes('<C-n>', true, false, true)
    end
end

-- live grep
function M.live_grep()
    local filename = vim.api.nvim_buf_get_name(0)
    local cwd = nil
    local prompt = " Grep > "
    local rg_cmd = "rg --line-number --column --multiline"
    if filename and filename ~= "" then
        cwd = vim.uv.fs_realpath(filename)
        if cwd then
            cwd = vim.fn.fnamemodify(cwd, ":h")
        end
    end
    if not cwd or cwd == "" then
        cwd = vim.fn.getcwd()
        print("Brak ścieżki pliku, używam bieżącego katalogu: " .. cwd)
    end
    require"fzf-lua".live_grep({
        prompt = prompt,
        cwd = cwd,
        cmd = rg_cmd,
        winopts = {
            fullscreen = true,
            title = " Grep "
        }
    })
end

function M.fzf_files()
    local rg_cmd = "rg --files --hidden --follow -g '!.git/'"
    require"fzf-lua".files({
        cmd = rg_cmd,
        winopts = {
            preview = { hidden = "nohidden" },
            title = " Wyszukiwarka plików ",
            fullscreen = true,
        },
        -- wyszukuje dokładnie tego co wprowadzimy w prompt
        fzf_opts = { ['--exact'] = '', ['--no-sort'] = '' },
    })
end

function M.neotree_symlink()
    local file_path = vim.api.nvim_buf_get_name(0)
    if file_path ~= "" then
        local resolved_path = vim.fn.resolve(file_path)
        local dir_path = vim.fn.fnamemodify(resolved_path, ":h")
        vim.cmd("Neotree dir=" .. dir_path .. " toggle")
    else
        vim.cmd('Neotree toggle')
    end
end

function M.create_floating_scratch(content)
    -- Get editor dimensions
    local width = vim.api.nvim_get_option_value("columns", {})
    local height = vim.api.nvim_get_option_value("lines", {})
    -- Calculate the floating window size
    local win_height = math.ceil(height * 0.8) + 2 -- Adding 2 for the border
    local win_width = math.ceil(width * 0.8) + 2 -- Adding 2 for the border
    -- Calculate window's starting position
    local row = math.ceil((height - win_height) / 2)
    local col = math.ceil((width - win_width) / 2)
    -- Create a buffer and set it as a scratch buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
    vim.api.nvim_set_option_value("filetype", "sh", { buf = buf })
    -- Create the floating window with a border and set some options
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = row,
        col = col,
        width = win_width,
        height = win_height,
        border = "single", -- You can also use 'double', 'rounded', or 'solid'
    })
    -- Check if we've got content to populate the buffer with
    if content then
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, content)
    else
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, { "This is a scratch buffer in a floating window." })
    end
    vim.api.nvim_set_option_value("wrap", false, { scope = "local", win = win })
    vim.api.nvim_set_option_value("number", false, { scope = "local", win = win })
    vim.api.nvim_set_option_value("cursorline", false, { scope = "local", win = win })
    -- Map 'q' to close the buffer in this window
    vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q!<CR>", { nowait = true, noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "n", "d", "<c-d>", { nowait = true, noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "n", "u", "<c-u>", { nowait = true, noremap = true, silent = true })
end

-- Standardowo zmienna $BM_DIRS zaweira nazwę pliku w której znajdują się często odwiedzane katalogi
-- Zazwyaczaj jest to plik $HOME/.config/bmdirs
function M.CD()
    if BmDirs == nil then
        BmDirs = vim.fn.resolve(vim.fn.expand('$HOME/.config/bmdirs'))
    end
    if vim.fn.filereadable(BmDirs) == 0 then
        vim.io.open(BmDirs, "a+")
    end
    local command = "cd"
    local opts = {}
    opts.prompt = "CD > "
    opts.winopts = { title = " Katalogi " }
    opts.actions = {
        ["default"] = function(selected)
            -- wywołanie komendy na wybranym katalogu
            local dir = vim.fn.expand(selected[1])
            if vim.fn.isdirectory(dir) == 1 then
                vim.cmd(command .. " " .. dir)
            else
                vim.notify("Katalog docelowy nie istnieje.")
            end
        end
    }
    local files = vim.fn.readfile(vim.fn.expand(BmDirs))
    require"fzf-lua".fzf_exec(files, opts)
end

-- Otwiera menadżer plików w wybranej lokalizacji
function M.CDE()
    if BmDirs == nil then
        BmDirs = vim.fn.resolve(vim.fn.expand("$HOME/.config/bmdirs"))
    end
    if vim.fn.filereadable(BmDirs) == 0 then
        vim.io.open(BmDirs, "a+")
    end
    -- local command = "Neotree float"
    local command = "Neotree"
    local opts = {}
    opts.prompt = "CDE > "
    opts.winopts = { title = " Katalogi " }
    opts.actions = {
        ["default"] = function(selected)
            -- wywołanie komendy na wybranym katalogu
            local dir = vim.fn.expand(selected[1])
            if vim.fn.isdirectory(dir) == 1 then
                vim.cmd(command .. " " .. dir)
            else
                vim.notify("Katalog docelowy nie istnieje.")
            end
        end
    }
    local files = vim.fn.readfile(vim.fn.expand(BmDirs))
    require"fzf-lua".fzf_exec(files, opts)
end

-- Otwiera wyszukiwanie fzf-lua.files w wybranym katalogu z bmdirs
function M.CDS()
    if BmDirs == nil then
        BmDirs = vim.fn.resolve(vim.fn.expand("$HOME/.config/bmdirs"))
    end
    if vim.fn.filereadable(BmDirs) == 0 then
        vim.io.open(BmDirs, "a+")
    end
    local opts = {}
    opts.prompt = "CDE > "
    opts.winopts = { title = " Katalogi " }
    opts.actions = {
        ["default"] = function(selected)
            -- wywołanie komendy na wybranym katalogu
            local dir = vim.fn.expand(selected[1])
            if vim.fn.isdirectory(dir) == 1 then
                require"fzf-lua".files({
                    prompt = opts.prompt,
                    cwd = dir,
                    winopts = {
                        preview = { hidden = "nohidden" },
                        title = " Wyszukiwarka plików ",
                        fullscreen = true,
                    }
                })
            else
                vim.notify("Katalog docelowy nie istnieje.")
            end
        end
    }
    local files = vim.fn.readfile(vim.fn.expand(BmDirs))
    require"fzf-lua".fzf_exec(files, opts)
end

-- Edycja pliku BmDirs
function M.EditCDDirs()
    if BmDirs == nil then
        BmDirs = vim.fn.resolve(vim.fn.expand("$HOME/.config/bmdirs"))
    end
    vim.cmd("e" .. BmDirs)
end

-- Dodaje bieżący katalog do pliku bmdirs
function M.AddCDDir()
    if BmDirs == nil then
        BmDirs = vim.fn.resolve(vim.fn.expand("$HOME/.config/bmdirs"))
    end
    local filename = vim.loop.fs_realpath(vim.api.nvim_buf_get_name(0))
    local directory = vim.fs.dirname(filename)
    if directory == nil then
        print("Plik nie ma swojego miejsca na dysku")
        return
    end
    local BmDirsHandle = io.open(BmDirs, "a+")
    if BmDirsHandle ~= nil then
        BmDirsHandle:write(directory .. "\n")
        BmDirsHandle:close()
    else
        vim.notify("Brak pliku " .. BmDirs)
    end
end

-- Dodaje edytowany plik do bmfiles
function M.AddBmFile()
    if BmFiles == nil then
        BmFiles = vim.fn.resolve(vim.fn.expand("$HOME/.config/bmfiles"))
    end
    local BmFilesHandle = io.open(BmFiles, "a+")
    local FileName = vim.fn.resolve(vim.fn.expand("%:p"))
    if BmFilesHandle ~= nil then
        BmFilesHandle:write(FileName .. "\n")
        BmFilesHandle:close()
    else
        vim.notify("Brak pliku " .. BmFiles)
    end
end

-- Pokazuje okno wyboru ulubionych plików
function M.BmFiles()
    if BmFiles == nil then
        BmFiles = vim.fn.resolve(vim.fn.expand("$HOME/.config/bmfiles"))
    end
    if vim.fn.filereadable(BmFiles) == 0 then
        vim.io.open(BmFiles, "a+")
    end
    local files = vim.fn.readfile(vim.fn.expand(BmFiles))
    local opts = {}
    opts.prompt = "Files > "
    opts.winopts = { title = " Ulubione pliki " }
    opts.actions = {
        ["default"] = function(selected)
            vim.cmd("e " .. selected[1])
        end
    }
    require"fzf-lua".fzf_exec(files, opts)
end

-- Edycja pliku bmfiles
function M.EditBmFiles()
    if BmFiles == nil then
        BmFiles = vim.fn.resolve(vim.fn.expand("$HOME/.config/bmfiles"))
    end
    vim.cmd("e" .. BmFiles)
end

function M.scratchpad(raw_args)
    local SP = SPDirENV or vim.fn.resolve(vim.fn.expand('$HOME/Notes/SP'))
    local sp_dir = vim.fn.expand(SP)
    if vim.fn.isdirectory(sp_dir) == 0 then
        vim.fn.mkdir(sp_dir, "p")
    end
    local words = {}
    if raw_args and raw_args ~= "" then
        for word in raw_args:gmatch("%S+") do
            table.insert(words, word)
        end
    end
    local name = words[1]
    local size = tonumber(words[2]) or 12
    local position = words[3] or "belowright"
    local full_path
    if name == nil or name == "" then
        local filename = string.format("sp-%s-%s.md", os.date("%Y-%m-%d"), os.time())
        full_path = sp_dir .. "/" .. filename
    else
        local expanded = vim.fn.expand(name)
        if expanded:find("/") then
            full_path = expanded
        else
            local clean_name = expanded:gsub("%.md$", "")
            full_path = sp_dir .. "/" .. clean_name .. ".md"
        end
    end
    local cmd = string.format("%s %dnew %s", position, size, vim.fn.fnameescape(full_path))
    vim.cmd(cmd)
    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].filetype   = "scratch"
    vim.bo[buf].buftype    = ""
    vim.bo[buf].bufhidden  = "wipe"
    vim.bo[buf].swapfile   = false
    if vim.fn.filereadable(full_path) == 0 then
        vim.cmd("w")
    end
    vim.cmd("startinsert")
end

-- pozwala wybrać nazwę tymczasowej notatki
function M.new_scratchpad()
    local sp = SPDirENV or vim.fn.resolve(vim.fn.expand('$HOME/Notes/SP'))
    vim.ui.input({
        prompt = 'Nazwa notatki: ',
        completion = 'file',
        default = sp,
    }, function(input)
        if input then
            -- Łączymy wpisaną nazwę z Twoimi stałymi parametrami
            require('functions').scratchpad(input .. " 20 topleft")
        end
    end)
end

function M.select_scratchpad()
    local SP = SPDirENV or vim.fn.resolve(vim.fn.expand('$HOME/Notes/SP'))
    local sp_dir = vim.fn.expand(SP)
    if vim.fn.isdirectory(sp_dir) == 0 then
        vim.fn.mkdir(sp_dir, "p")
    end
    local cwd_dir = vim.fs.normalize(sp_dir)
    require('fzf-lua').files({
        prompt       = "Search " .. cwd_dir .. ": ",
        cmd          = "fd -t f -H -g 'sp-*.md' | xargs eza --sort=modified --reverse",
        cwd          = cwd_dir,
        cwd_prompt   = false,
        cwd_header   = false,
        winopts = {
            preview    = { hidden = "nohidden" },
            title      = " Scratchpad ",
            fullscreen = true,
        },
        actions = {
            ["default"] = function(selected, opts)
                if selected and selected[1] then
                    local entry = require('fzf-lua.path').entry_to_file(selected[1], opts)
                    require('functions').scratchpad(entry.path)
                end
            end
        }
    })
end

function M.last_scratchpad()
    local sp = OBS_SP or vim.fn.resolve(vim.fn.expand('$HOME/Obsidian/SP'))
    local latest = require('functions').get_latest_modified_file(sp)
    if latest then
        local file = vim.fn.fnameescape(latest)
        require('functions').scratchpad(file)
    end
end

-- otwiera wybrany plik Scratchpad*.md jako normalny bufor
function M.obsidian_scratchpad()
    local sp = OBS_SP or vim.fn.resolve(vim.fn.expand('$HOME/Obsidian/SP'))
    local cwd_dir = vim.fs.normalize(sp)
    require('fzf-lua').files({
        prompt       = "Obsidian/SP: ",
        cmd          = "fd -t f -H -g 'Scratchpad*.md' | xargs eza --sort=modified --reverse",
        cwd          = cwd_dir,
        cwd_prompt   = false,
        cwd_header   = false,
        winopts = {
            preview    = { hidden = "nohidden" },
            title      = " Scratchpad ",
            fullscreen = true,
        },
    })
end

-- pobiera obecny schemat kolorystyczny
function M.get_current_colorscheme()
    if vim.g.colors_name then
        return vim.g.colors_name
    else
        return "default"
    end
end

-- wybór schematu kolorystycznego
function M.kolory()
    local current_colorscheme = M.get_current_colorscheme()
    local kolory = {
        'bamboo',
        'everforest',
        'habamax',
        'kanagawa-wave',
        'nordic',
        'rose-pine-main',
        'rose-pine-moon',
        'tokyonight-moon',
        'tokyonight-storm',
    }
    local opts = {}
    vim.notify("Kolor: " .. current_colorscheme, vim.log.levels.INFO)
    table.insert(kolory, 1, current_colorscheme)
    opts.prompt = " Wyszukaj > "
    opts.preview = function(selected)
        if not selected or selected == "" then
            return
        end
        vim.cmd.colorscheme(selected)
        vim.o.background = "dark"
    end
    opts.winopts = { title = " Kolory ", width = 33, height = 22, backdrop = 100 }
    opts.fzf_opts = { ["--preview-window"] = "nohidden:right:0" }
    require "fzf-lua".fzf_exec(kolory, opts)
end

function M.komendy()
    -- lista par: { "nazwa w menu", funkcja_lub_komenda }
    local menu_items = {
        { "kolorki", M.kolory },
        { 'toggle number', function() vim.cmd('set number!') end },
        { 'toggle relativenumber', function() vim.cmd('set relativenumber!') end },
        { 'toggle lines wrap', function() vim.cmd('set wrap!')end },
        { 'enable whichkey', function()
            vim.pack.add({ { src = "https://github.com/folke/which-key.nvim" }, })
            require("which-key")
        end },
        { 'scratchpad - nowy plik', function() require('functions').scratchpad() end },
        { 'scratchpad - nowy plik (podaj nazwę)', function() require('functions').new_scratchpad() end },
        { 'scratchpad - wybór istniejącego pliku', function() require('functions').select_scratchpad() end },
        { 'scratchpad - ostatnio modyfikowany plik', function() require('functions').last_scratchpad() end },
        { 'pomo 1m', function() vim.cmd[[TimerStart 1m]] end, { desc = 'uruchamia timer na 1 minutę' }},
        { 'pomo 3m', function() vim.cmd[[TimerStart 3m]] end, { desc = 'uruchamia timer na 3 minuty' }},
        { 'pomo 15m', function() vim.cmd[[TimerStart 15m]] end, { desc = 'uruchamia timer na 15 minut' }},
        { 'pomo 30m', function() vim.cmd[[TimerStart 30m]] end, { desc = 'uruchamia timer na 30 minut' }},
        { 'restart', function() vim.cmd[[Restart]] end, { desc = 'uruchamia ponownie Neovim' }},
        { 'copy file name', function() M.copy_filename() end, { desc = 'kopiuje nazwę pliku do schowka' }},
        { 'file info', function() M.file_info() end, { desc = 'wyświetla informacje o pliku' }},
        { 'keymaps', function() M.keymaps() end, { desc = 'wyświetla skróty klawiszowe' }},
        { 'QFJZ Notes', function() require('functions').fzf_md_files(QFJZ_Notes_Dir, 0) end },
        { 'QFJZ Notes - ostatnio modyfikowane', function() require('functions').fzf_md_files(QFJZ_Notes_Dir, 1) end },
        { 'open in Neovide', function() M.open_in_neovide() end, { desc = 'otwiera plik w Neovide' }},
        { 'Neovide settings', function() M.neovide_settings() end, { desc = 'ustawienia Neovide' }},
        { 'Snacks', function() M.snacks() end, { desc = 'Snacks' }},
        { 'ShowkeysToggle', function() vim.cmd[[ShowkeysToggle]] end, { desc = 'pokazuje wciskane klawisze' }},
        { 'sortowanie buforów po numerze', function() vim.cmd[[BufferOrderByBufferNumber]] end, { desc = 'sortowanie buforów po numerze' }},
        { 'sortowanie buforów po katalogu', function() vim.cmd[[BufferOrderByDirectory]] end, { desc = 'sortowanie buforów po katalogu' }},
        { 'zamknij wszystkie bufory poza bieżącym', function() vim.cmd[[BufferCloseAllButCurrent]] end, { desc = 'sortowanie buforów po katalogu' }},
    }
    -- 1. wyciągamy same nazwy do wyświetlenia (zachowując kolejność z menu_items)
    local lista_wyswietlana = {}
    for _, item in ipairs(menu_items) do
        table.insert(lista_wyswietlana, item[1])
    end
    require("fzf-lua").fzf_exec(lista_wyswietlana, {
        prompt = " wyszukaj > ",
        winopts = { title = " komendy ", fullscreen = false },
        actions = {
            ["default"] = function(selected)
                local choice = selected[1]
                -- 2. szukamy wybranej nazwy w naszej liście i odpalamy przypisaną funkcję
                for _, item in ipairs(menu_items) do
                    if item[1] == choice then
                        item[2]()
                        break
                    end
                end
            end
        }
    })
end

function M.new_task(filepath)
    filepath = vim.fs.normalize(filepath)
    if vim.fn.filereadable(filepath) == 0 then
        vim.notify("Plik nie istnieje lub nie można go odczytać: " .. filepath, vim.log.levels.WARN)
        return
    end
    vim.ui.input({
        prompt = "Nowe zadanie: ",
    }, function(input)
        if not input or input == "" then
            vim.notify("Anulowano – nic nie dodano", vim.log.levels.INFO)
            return
        end
        local current_date = os.date("%Y-%m-%d")
        local new_task_line = "- [ ] ⏳ " .. current_date .. " " .. input
        local lines = vim.fn.readfile(filepath)
        local new_content = {}
        local header_found = false
        local tasks = {}
        for _, line in ipairs(lines) do
            local trimmed = vim.trim(line)
            if trimmed:match("^%s*#+%s*[Zz]adania%s*$") then
                header_found = true
                table.insert(new_content, line)           -- nagłówek
                table.insert(new_content, "")             -- jedna pusta linia
                table.insert(new_content, new_task_line)  -- nowe zadanie
                goto continue
            end
            if header_found then
                if vim.trim(line) ~= "" then
                    table.insert(tasks, line)
                end
            else
                table.insert(new_content, line)
            end
            ::continue::
        end
        if header_found then
            for _, task_line in ipairs(tasks) do
                table.insert(new_content, task_line)
            end
        else
            -- Brak nagłówka → dodajemy na końcu BEZ duplikowania treści
            -- new_content zawiera już całą oryginalną zawartość, więc tylko dopisujemy
            if #new_content > 0 and vim.trim(new_content[#new_content]) ~= "" then
                table.insert(new_content, "")
            end
            table.insert(new_content, "# Zadania")
            table.insert(new_content, "")
            table.insert(new_content, new_task_line)
        end
        local ok, err = pcall(function()
            vim.fn.writefile(new_content, filepath)
        end)
        if ok then
            vim.notify("Dodano zadanie z datą " .. current_date, vim.log.levels.INFO)
        else
            vim.notify("Błąd zapisu pliku: " .. tostring(err), vim.log.levels.ERROR)
        end
    end)
end

function M.choose_tasks_file()
    require('fzf-lua').files({
        prompt = 'Wybierz plik do dodania zadania > ',
        cmd   = 'fd --type f --follow --hidden --maxdepth 2 --no-ignore --glob "*.md"',
        -- ↑ możesz zmienić rozszerzenia lub usunąć --hidden / --no-ignore
        cwd   = vim.fn.expand('~/'),   -- ← zmień na swój katalog bazowy
        actions = {
            -- po naciśnięciu Enter na pliku
            ['default'] = function(selected, opts)
                if #selected == 0 then return end
                local path_util = require('fzf-lua.path')
                local entry = path_util.entry_to_file(selected[1], opts)
                local full_path = entry.path
                if full_path and not path_util.is_absolute(full_path) then
                    full_path = vim.fs.joinpath(opts.cwd or vim.loop.cwd(), full_path)
                end
                vim.notify("Wybrano: " .. full_path)
                require('functions').new_task(full_path)
            end,
        },
        winopts = {
            height   = 0.80,
            width    = 0.90,
            row      = 0.10,
            col      = 0.05,
            preview  = { hidden = 'nohidden' },   -- możesz zmienić na 'hidden'
            title    = ' Dodaj zadanie do pliku ',
        },
    })
end

function M.notes_files()
    if Notes_Dir == nil then
        Notes_Dir = vim.fn.resolve(vim.fn.expand('$HOME/Notes/'))
    end
    if vim.fn.isdirectory(Notes_Dir) == 0 then
        vim.notify('Brak katalogu ' .. Notes_Dir,  4)
        return
    end
    local rg_cmd = "fd -I -t f --follow -H -g '*.md' --strip-cwd-prefix -X eza -1 --sort=modified --reverse"
    local cwd_dir = Notes_Dir
    local prompt = " Notes > "
    require"fzf-lua".files({
        prompt = prompt,
        cwd = cwd_dir,
        cmd = rg_cmd,
        winopts = {
            preview = { hidden = "nohidden" },
            title = " Notes ",
            fullscreen = true,
        }
    })
end

-- przeszukiwanie plików Markdown w podanym katalogu
-- jeśli drugi parametr to 1 jako pierwsze wyświetla pliki ostatnio modyfikowane
function M.fzf_md_files(dir, mode)
    local expanded = dir and vim.fn.expand(dir) or ""
    -- if not dir or vim.fn.isdirectory(expanded) == 0 then
    if not dir or vim.fn.isdirectory(expanded) == nil then
        local msg = dir and ('Katalog ' .. dir .. ' nie istnieje') or 'Nie podano katalogu'
        vim.notify(msg, 4)
        return
    end
    local cwd_dir = vim.fs.normalize(expanded)
    local cmd_str
    if mode == 1 then
        cmd_str = "fd -I -t f --follow -H -g '*.md' --strip-cwd-prefix -X eza -1 --sort=modified --reverse"
    else
        cmd_str = "fd -I -t f --follow -H -g '*.md' --strip-cwd-prefix"
    end
    require('fzf-lua').files({
        prompt       = "Search : ",
        cmd          = cmd_str,
        cwd          = cwd_dir,
        cwd_prompt   = false,
        cwd_header   = false,
        winopts = {
            preview    = { hidden = "nohidden" },
            title      = " Search ",
            fullscreen = true,
        },
        fzf_opts = { ['--exact'] = '', ['--no-sort'] = '' },
    })
end

--- Znajduje ostatnio modyfikowany plik w podanym katalogu
--- @param dir string Ścieżka do katalogu (np. "~/tmp")
--- @return string|nil ścieżka do pliku lub nil jeśli katalog pusty
function M.get_latest_modified_file(dir)
  dir = vim.fs.normalize(dir)  -- rozwinie '~' na prawidłową ścieżkę na przykład /home/user
  local latest_file = nil
  local latest_mtime = 0
  -- Iterujemy po wszystkich plikach w katalogu
  for name, type in vim.fs.dir(dir) do
    if type == 'file' then
      local path = vim.fs.joinpath(dir, name)
      local stat = vim.loop.fs_stat(path)
      if stat and stat.mtime.sec > latest_mtime then
        latest_mtime = stat.mtime.sec
        latest_file = path
      end
    end
  end
  return latest_file
end

-- wymaga ustawienia przezroczystości w terminalu
function M.set_transparent()
    local groups = {
        'Normal',
        'NormalNC',
        'EndOfBuffer',
        'NormalFloat',
        'FloatBorder',
        'SignColumn',
        'StatusLine',
        'StatusLineNC',
        'TabLine',
        'TabLineFill',
        'TabLineSel',
        'ColorColumn',
    }
    for _, g in ipairs(groups) do
        vim.api.nvim_set_hl(0, g, { bg = 'NONE' })
    end
    vim.api.nvim_set_hl(0, 'TabLineFill', { bg = 'NONE', fg = '#767676' })
end

-- tworzy katalog o nazwie wyrazu pod kursorem, jeśli chcesz utworzyć podkatalog pamiętaj żeby dodać '/' na końcu
function M.gd()
    local fidget = require("fidget")
    local home = os.getenv("HOME")
    local cfile = vim.fn.resolve(vim.fn.expand("<cfile>"))
    local file_dir = vim.fn.substitute(cfile, "\\~", home, "")
    if vim.fn.isdirectory(file_dir) == 1 then
        -- katalog istnieje
        -- Otwiera wyszukiwarkę plików
        fidget.notify(file_dir, vim.log.levels.INFO, { annote = Filename, key = "GD" })
        require('fzf-lua').files({
            prompt = "Pliki",
            cwd = file_dir,
            winopts = {
                preview = { hidden = "nohidden" },
                title = " Wyszukiwarka plików ",
                fullscreen = true,
            }
        })
    else
        if vim.fn.filereadable(file_dir) == 1 then
            -- to jest plik
            -- Otwiera plik
            vim.cmd("edit " .. file_dir)
        else
            -- ścieżka nie istnieje, otwiera okno do podania katalogu do utworzenia
            vim.ui.input({ prompt = "Podaj nazwę katalogu", default = file_dir .. "/", },
                function(input)
                    if not input then
                        return
                    end
                    if input:gsub("^%s+", ""):gsub("%s+$", "") == "" then
                        return vim.notify("Podaj nazwę katalogu")
                    end
                    local dir = vim.fs.dirname(input)
                    if vim.fn.isdirectory(dir) == 0 then
                        vim.fn.mkdir(dir, "p")
                        fidget.notify("Utworzyłem katalog" .. " " .. dir, vim.log.levels.INFO, { annote = Filename, key = "GD" })
                    end
                end)
        end
    end
end

-- kopiuje nazwę pliku do schowka systemowego
function M.copy_filename()
    local filename = vim.fn.resolve(vim.fn.expand("%:p"))
    vim.fn.setreg([[*]], filename, '1')
    -- vim.fn.setreg([[+]], filename, 1)
end

function M.keymaps(category_name)
    local fzf = require('fzf-lua')
    local data = {
        tasks = {
            { "<leader>sn", "dodaj nowe zadanie do wybranego pliku" },
            { "<leader>st", "dodaj nowe zadanie w pliku ~/todo.md (new_task)" },
        },
        scratchpad = {
            { "<leader>ss", "wyszukiwarka plików SP (select_scratchpad)" },
        },
        inne = {
            { "<tab>", "przełącza się pomiędzy dwoma ostatnio otwieranymi plikami" },
            { "qq", "opuść Neovim" },
            { "<localleader>r", "restart Neovim" },
            { '<leader>co', 'pozostawia otwarte tylko aktywne okno'},
            { '<leader>cc', 'zamyka okno'},
            { '<leader>o', 'Snacks zoom'},
            { ';', 'wejście do trybu COMMAND'},
            { ':', 'historia komend'},
        }
    }
    if not category_name or (not data[category_name] and category_name ~= "wszystkie") then
        category_name = "wszystkie"
    end
    local selected_list = {}
    if category_name == "wszystkie" then
        for _, list in pairs(data) do
            for _, item in ipairs(list) do
                table.insert(selected_list, item)
            end
        end
    else
        selected_list = data[category_name]
    end
    local entries = {}
    for _, item in ipairs(selected_list) do
        table.insert(entries, string.format("%-27s | %s", item[1], item[2]))
    end
    fzf.fzf_exec(entries, {
        prompt = "Skróty (" .. category_name .. ")> ",
        fzf_opts = {
            ["--extended"] = true,
        },
        actions = {
            ["default"] = function(selected)
                print("Wybrano: " .. selected[1])
            end
        },
        winopts = {
            height = 0.8,
            width = 0.9,
            row = 0.5,
        }
    })
end

function M.file_info()
    require("functions").cdfd('ziuta')
    local root_dir
    local msg = ''
    local result = vim.fn.system("git rev-parse --is-inside-work-tree")
    if vim.v.shell_error == 0 and result:find("true") then
        root_dir = vim.fn.system("git rev-parse --show-toplevel")
    end
    local filename=vim.fn.resolve(vim.fn.expand("%:p"))
    msg = msg .. " Nazwa: " .. filename .. " \n Mod: " .. vim.fn.strftime("%F %T",vim.fn.getftime(filename)) .. "\n Size: " ..  require("functions").file_size() .. ", TL# " .. require("functions").total_lines() .. "\n Git: " .. root_dir
    if vim.fn.empty(msg) == 1 then
        vim.notify('Brak informacji o pliku', vim.log.levels.WARN)
      return
    end
    local buf = vim.api.nvim_create_buf(false, true)
    local lines = vim.split(msg, '\n')
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
    vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })
    vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
    local width = math.min(66, vim.o.columns - 4)
    local height = math.min(6, vim.o.lines - 4)
    vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        col = (vim.o.columns - width) / 2,
        row = (vim.o.lines - height) / 2,
        style = 'minimal',
        border = 'single',
    })
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, nowait = true })
    vim.keymap.set("n", "<cr>", "<cmd>close<CR>", { buffer = buf, nowait = true })
end

function M.file_size()
    local file = vim.fn.resolve(vim.fn.expand("%:p"))
    local size = vim.fn.getfsize(file)
    if size <= 0 then
        return ""
    end
    local sufixes = { "b", "k", "m", "g" }
    local i = 1
    while size > 1024 do
        size = size / 1024
        i = i + 1
    end
    return string.format("%.1f%s", size, sufixes[i])
end

function M.total_lines()
    local tl = vim.fn.line("$")
    return tl
end

-- MacOS
function M.open_in_neovide()
    local file_path = vim.fn.expand("%:p")
    if file_path ~= "" then
        local neovide_bin = vim.fn.trim(vim.fn.system([[ find $(brew --prefix 2>/dev/null || echo /opt/homebrew)/Cellar/neovide -name neovide -type f -perm +111 -print -quit 2>/dev/null ]]))
        vim.fn.system({neovide_bin, file_path})
        print("Opened file in Neovide: " .. file_path)
    else
        print("No file is currently open")
    end
end

function M.neovide_settings()
    if not vim.g.neovide then
        vim.notify("To nie jest Neovide")
        return
    end
    local menu_items = {
        { 'Neovide version', function() vim.notify(vim.g.neovide_version) end },
        { 'Ustawia przezroczystość na 0.2', function() vim.cmd[[lua vim.g.neovide_opacity = 0.2]] end },
        { 'Ustawia przezroczystość na 0.7', function() vim.cmd[[lua vim.g.neovide_opacity = 0.7]] end },
        { 'Ustawia przezroczystość na 1', function() vim.cmd[[lua vim.g.neovide_opacity = 1]] end },
        { 'Zmień odstęp pomiędzy liniami na 0', function() vim.cmd('lua vim.opt.linespace = 0') end },
        { 'Zmień odstęp pomiędzy liniami na 10', function() vim.cmd('lua vim.opt.linespace = 10') end },
        { 'Zmień rozmiar czcionki na 12', function() vim.cmd[[lua vim.o.guifont = "ComicShannsMono Nerd Font Mono:h12"]] end },
        { 'Zmień rozmiar czcionki na 18', function() vim.cmd[[lua vim.o.guifont = "ComicShannsMono Nerd Font Mono:h18"]] end },
        { 'Zmień rozmiar czcionki na 21', function() vim.cmd[[lua vim.o.guifont = "ComicShannsMono Nerd Font Mono:h21"]] end },
    }
    local lista_wyswietlana = {}
    for _, item in ipairs(menu_items) do
        table.insert(lista_wyswietlana, item[1])
    end
    require("fzf-lua").fzf_exec(lista_wyswietlana, {
        prompt = " wyszukaj > ",
        winopts = { title = " komendy ", fullscreen = false },
        actions = {
            ["default"] = function(selected)
                local choice = selected[1]
                for _, item in ipairs(menu_items) do
                    if item[1] == choice then
                        item[2]()
                        break
                    end
                end
            end
        }
    })
end

function M.snacks()
    local menu_items = {
        { 'Snacks Files', function() Snacks.picker.files() end },
        { 'Snacks Colorschemes', function() Snacks.picker.colorschemes() end },
        { 'Snacks Grep', function() Snacks.picker.grep() end },
        { 'Snacks Buffers', function() Snacks.picker.buffers() end },
        { 'Snacks Commands', function() Snacks.picker.commands() end },
    }
    local lista_wyswietlana = {}
    for _, item in ipairs(menu_items) do
        table.insert(lista_wyswietlana, item[1])
    end
    require("fzf-lua").fzf_exec(lista_wyswietlana, {
        prompt = " wyszukaj > ",
        winopts = { title = " komendy ", fullscreen = false },
        actions = {
            ["default"] = function(selected)
                local choice = selected[1]
                for _, item in ipairs(menu_items) do
                    if item[1] == choice then
                        item[2]()
                        break
                    end
                end
            end
        }
    })
end

return M
