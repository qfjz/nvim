-- autocmd.lua

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

autocmd({ "RecordingLeave", }, {
    group = augroup("NotifyMacroStop", { clear = true }),
    callback = function()
        local msg = "Zakończyłem nagrywać makro " .. "[" .. vim.fn.reg_recording() .. "]"
        vim.notify(msg, "info", {
            timeout = 6000,
        })
    end,
})

autocmd("FileType", {
    pattern = { 'oil', 'nvim-undotree' },
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
    end,
})
