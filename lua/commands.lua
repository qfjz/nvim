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
