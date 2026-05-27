require('mini.files').setup({
    mappings = {
        close       = 'q',
        go_in       = '<cr>',
        go_in_plus  = 'L',
        go_out      = '_',
        go_out_plus = 'H',
        mark_goto   = "'",
        mark_set    = 'm',
        reset       = '<bs>',
        reveal_cwd  = '@',
        show_help   = 'g?',
        synchronize = '=',  -- potwierdzenie operacji usunięćia, utworzenia czy zmiany nazwy pliku
        trim_left   = '<',
        trim_right  = '>',
    },
    options = {
        permanent_delete = true,
        use_as_default_explorer = true,
        lsp_timeout = 1000,
    },
    windows = {
        max_number = math.huge,
        preview = false,
        width_focus = 50,
        width_nofocus = 15,
        width_preview = 55,
    },
})

require('mini.surround').setup()
