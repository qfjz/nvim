local ok, gitsigns = pcall(require, 'gitsigns')
if ok then
    gitsigns.setup({
        signcolumn              = false,
        numhl                   = true,
        current_line_blame      = true,
        word_diff               = false,
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
            delay = 1000,
            ignore_whitespace = false,
            virt_text_priority = 100,
            use_focus = true,
        },
    })
end
