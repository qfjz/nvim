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

return M
