# Komendy

| Komenda          | Opis                                                          |
|------------------|---------------------------------------------------------------|
| `Diff`           | uruchamia polecenie `git diff`                                |
| `Scratch`        | uruchamia tymczasowy notatnik                                 |
| `CopyFileName`   | kopiuje pełną ścieżkę i nazwę pliku do standardowego rejestru |
| `EditCDDirs`     | edycja pliku `bmdirs`                                         |
| `AddBmFile`      | dodaje biężący plik do `bmfiles`                              |
| `BmFiles`        | otwiera listę plików `bmfiles`                                |
| `EditBmFiles`    | edycja pliku `bmfiles`                                        |
| `NewSP`          | tworzy nowy notatnik tymczasowy                               |
| `SP`             | wybiera notatnik tymczasowy do edycji                         |
| `ObsSP`          | wybór tymczasowego notatnika z katalogu Obsidian.md           |
| `Kolory`         | zmiana schematu kolorystycznego                               |
| `WhichKeyEnable` | uruchamia WhichKey                                            |
| `Restart`        | restartuje Neovim i otwiera poprzednią sesję                  |
| `Messages`       | wyświetla ostatnie komunikaty za pomocą `NoiceAll`            |
| `PackAdd`        | dodaje plugin, należy podać pełny adres URL                   |
| `PackDel`        | usuwa plugin                                                  |
| `PackUpdate`     | aktualizuje pluginy                                           |
| `MiniFiles`      | otwiera menadżer plików MiniFiles                             |
| `BufFormat`      | formatuje plik w otwartym buforze                             |

## Komendy oferowane przez pluginy

Lista pomocnych komend dostarczanych przez pluginy

| Komenda                     | Opis                                        |
|-----------------------------|---------------------------------------------|
| `BarbarDisable`             | wyłączenie Barbar                           |
| `BarbarEnable`              | wyłączenie Barbar                           |
| `BufferCloseAllButCurrent`  | zamyka wszystkie bufory poza aktywnym       |
| `BufferOrderByBufferNumber` | sortuje bufory po numerze                   |
| `BufferPick`                | wybór bufora za pomocą jednego klawisza     |
| `BufferRestore`             | otwiera wcześniej zamknięty bufor           |
| `FzfLua`                    | zestaw komend FzfLua                        |
| `Gitsigns`                  | zestaw komend Gitsigns                      |
| `InspectTree`               | uruchamia TreeSitter w trybie interaktywnym |
| `Mason`                     | instalacja LSP                              |
| `NoiceAll`                  | wyświetla komunikaty                        |
| `Oil`                       | uruchamia menadżer plików Oil               |
| `Open`                      | otwiera plik w domyślnym programie          |
| `ShowkeysToggle`            | wyświetlanie wduszanych klawiszy            |
| `Telescope`                 | zestaw komend Telescope                     |
| `TimerStart`                | uruchamia pomodoro                          |
| `TimerStop`                 | zatrzymuje pomodoro                         |

## Diff

```code
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
```

## Scratch

Otwiera bufor tymczasowy, którego zawartość znika wraz z zamknięciem okna

```code
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
```

## CopyFileName

Kopiuje nazwę otwartego bufora do rejestru `"`

```code
vim.api.nvim_create_user_command("CopyFileName", function()
    Filename=vim.fn.resolve(vim.fn.expand("%:p"))
    vim.fn.setreg([["]], Filename, '')
end, { desc = 'Kopiuje pełną ścieżkę i nazwę pliku' })
```

## EditCDDirs

```code
vim.api.nvim_create_user_command("EditCDDirs", function()
    require('functions').EditCDDirs()
end, { desc = 'Edycja pliku BmDirs' })

```

## AddBmFile

```code
vim.api.nvim_create_user_command("AddBmFile", function()
    require('functions').AddBmFile()
end, { desc = 'Dodaje bieżący plik do BmFiles' })

```

## BmFiles

```code
vim.api.nvim_create_user_command("BmFiles", function()
    require('functions').BmFiles()
end, { desc = 'Otwiera listę BmFiles' })

```

## EditBmFiles

```code
vim.api.nvim_create_user_command("EditBmFiles", function()
    require('functions').EditBmFiles()
end, { desc = 'Edycja pliku BmFiles' })

```

## NewSP

```code
vim.api.nvim_create_user_command('NewSP', function()
    require('functions').scratchpad()
end, { desc = 'Tworzy nowy notatnnik tymczasowy' })

```

## SP

```code
vim.api.nvim_create_user_command('SP', function()
    require('functions').select_scratchpad()
end, { desc = 'Wybiera notatnik tymczasowy do edycji' })

```

## ObsSP

```code
vim.api.nvim_create_user_command('ObsSP', function()
    require('functions').obsidian_scratchpad()
end, { desc = 'Wybór tymczasowego notatnika z katalogu Obsidian' })

```

## Kolory

```code
vim.api.nvim_create_user_command('Kolory', function()
    require('functions').kolory()
end, { desc = 'Zmina schematu kolorystycznego' })

```

## WhichKeyEnable

```code
vim.api.nvim_create_user_command('WhichKeyEnable', function()
    vim.pack.add({
        { src = "https://github.com/folke/which-key.nvim" },
    })
    require("which-key")
end, { desc = 'Uruchamia WhichKey' })

```

## Restart

```code
vim.api.nvim_create_user_command('Restart', function()
    tmp_dir = vim.fn.resolve(vim.fn.expand('$HOME/tmp/'))
    if vim.fn.isdirectory(tmp_dir) == 0 then
        vim.fn.mkdir(tmp_dir, "p")
    end
    vim.cmd[[mksession! ~/tmp/nvimsession]]
    vim.cmd[[restart source ~/tmp/nvimsession | !rm ~/tmp/nvimsession]]
end, { desc = 'Restart' })

```

## Messages

```code
vim.api.nvim_create_user_command('Messages', [[NoiceAll]], {})

```

## PackAdd

```code
vim.api.nvim_create_user_command('PackAdd', function(opts)
    vim.pack.add(opts.fargs)
end, { nargs = '+', desc = 'Dodaje plugin, należy podać pełny adres URL' })

```

## PackDel

```code
vim.api.nvim_create_user_command('PackDel', function(opts)
    vim.pack.del(opts.fargs)
end, { nargs = '+' })

```

## PackUpdate

```code
vim.api.nvim_create_user_command('PackUpdate', function(opts)
    if opts.args:match('%S') then
        local plugins = vim.split(opts.args, '%s+', { trimempty = true })
        vim.pack(plugins)
    else
        vim.pack.update()
    end
end, { desc = 'Pack Update' })

```

## MiniFiles

Uruchomienie menadżera plików MiniFiles

```code
vim.api.nvim_create_user_command('MiniFiles', function()
    MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
    MiniFiles.reveal_cmd()
end, { desc = 'Mini Files Open' })

```

## BufFormat

```code
vim.api.nvim_create_user_command('BufFormat', function()
    vim.lsp.buf.format()
end, { desc = 'Formatowanie tekstu bufora' })

```
