require('pomo').setup({
    update_interval = 1000,
    notifiers = {
        {
            -- name = "Default",  -- wyświetla za pomocą powiadomień Neovim
            name = "System",  -- wyświetla za pomocą powiadomień systemowych
            opts = {
                sticky = true,
                -- title_icon = "󱎫",
                -- text_icon = "󰄉",
                title_icon = "⏳",
                text_icon = "⏱️",
            },
        },
    },
})
