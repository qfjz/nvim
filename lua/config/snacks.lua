require('snacks').setup({
    bigfile = { enabled = true },
    dashboard = { enabled = false, },
    explorer = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = {
        enabled = false,
        timeout = 3000,
    },
    picker = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    styles = {
        notification = {
            -- wo = { wrap = true } 
        }
    },
    {
      dashboard = { example = "github" }
    }
})
