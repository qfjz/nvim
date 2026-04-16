local M = {}

local config_dir = vim.fn.stdpath("config")
local BmDirs = os.getenv("BM_DIRS")
local BmFiles = os.getenv("BM_FILES")
local SPDirENV = os.getenv("SPDir")
local OBS_SP = os.getenv("OBS_SP")

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

-- wyświetla informacje o pliku
function M.file_info()
    local git_root = ''
    local filename=vim.fn.resolve(vim.fn.expand("%:p"))
    vim.fn.setreg([[*]], filename, 'c')
    local result = vim.fn.system("git rev-parse --is-inside-work-tree")
    if vim.v.shell_error == 0 and result:find("true") then
        git_root = (vim.fn.system("git rev-parse --show-toplevel"))
    end
    local msg = ""
    msg = msg .. filename .. "\nMod: " .. vim.fn.strftime("%F %T",vim.fn.getftime(filename)) .. "\nGit: "  .. git_root
    vim.notify(msg, "info", {
        timeout = 6000,
        title = "Informacje o pliku",
    })
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
    local rg_cmd = "rg --files --hidden --follow"
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

function M.select_scratchpad()
    local SP = SPDirENV or vim.fn.resolve(vim.fn.expand('$HOME/Notes/SP'))
    local sp_dir = vim.fn.expand(SP)
    if vim.fn.isdirectory(sp_dir) == 0 then
        vim.fn.mkdir(sp_dir, "p")
    end
    local cwd_dir = vim.fs.normalize(sp_dir)
    require('fzf-lua').files({
        prompt       = "Search " .. cwd_dir .. ": ",
        cmd          = "fd -t f -H -g '*.md' | xargs eza --sort=modified --reverse",   -- najnowsze na górze
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

return M
