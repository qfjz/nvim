vim.api.nvim_create_user_command("Diff", function()
    vim.cmd "w"
    local file_path = vim.fn.expand "%"
    local result = vim.fn.systemlist { "git", "diff", "--unified=0", "--", file_path }
    if vim.tbl_isempty(result) then
        print("Brak zmian w pliku " .. file_path)
        return
    end
    require("functions").create_floating_scratch(result)
end, { desc = "Pokazuje zmiany w otwartym pliku" })

vim.api.nvim_create_user_command("Scratch", function()
    vim.cmd("belowright 12new")
    local buf = vim.api.nvim_get_current_buf()
    for option, value in pairs {
        filetype = "scratch",
        buftype = "nofile",
        bufhidden = "wipe",
        buflisted = true,
        swapfile = false,
        modifiable = true,
    } do
        vim.api.nvim_set_option_value(option, value, { buf = buf })
    end
    vim.cmd[[startinsert]]
end, { desc = 'Open a scratch buffer', nargs = 0 })

vim.api.nvim_create_user_command("CopyFileName", function()
    Filename=vim.fn.resolve(vim.fn.expand("%:p"))
    vim.fn.setreg([["]], Filename, '')
end, { desc = 'Kopiuje pełną ścieżkę i nazwę pliku' })

vim.api.nvim_create_user_command("EditCDDirs", function()
    require('functions').EditCDDirs()
end, { desc = 'Edycja pliku BmDirs' })

vim.api.nvim_create_user_command("AddBmFile", function()
    require('functions').AddBmFile()
end, { desc = 'Dodaje bieżący plik do BmFiles' })

vim.api.nvim_create_user_command("BmFiles", function()
    require('functions').BmFiles()
end, { desc = 'Otwiera listę BmFiles' })

vim.api.nvim_create_user_command("EditBmFiles", function()
    require('functions').EditBmFiles()
end, { desc = 'Edycja pliku BmFiles' })
