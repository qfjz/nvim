-- autocmd.lua

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local api = vim.api

autocmd({ "RecordingLeave", }, {
    group = augroup("NotifyMacroStop", { clear = true }),
    callback = function()
        local msg = "Zakończyłem nagrywać makro " .. "[" .. vim.fn.reg_recording() .. "]"
        vim.notify(msg, "info", {
            timeout = 6000,
        })
    end,
})

autocmd({ "FileType", "BufEnter" }, {
    pattern = "oil",
    callback = function()
        vim.opt.number = false
    end,
})
