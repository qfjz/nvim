local M = {}

function M.config_files()
    -- local rg_cmd = "rg --files --follow -g '!plugin/' -g '*.lua'"
    local rg_cmd = "fd -I -t f -H -g '*.lua' | xargs eza --sort=modified --reverse"
    local cwd_dir = vim.fn.stdpath("config")
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

return M
