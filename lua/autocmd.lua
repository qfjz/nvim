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

autocmd('TermOpen', {
    group = augroup('startinsert', {}),
    callback = function()
        vim.cmd.startinsert()
    end,
})

-- zapisanie pozycji kursora
autocmd('BufReadPost', {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

autocmd('FileType', {
    group = augroup('close_with_q', {}),
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
