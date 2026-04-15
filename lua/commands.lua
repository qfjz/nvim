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
