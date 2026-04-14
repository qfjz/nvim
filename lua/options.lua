vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.virtualedit = 'all'
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.background = 'dark'
vim.opt.signcolumn = 'yes'
vim.opt.scrolloff = 3
vim.opt.sidescrolloff = 8
vim.opt.cursorline = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.backspace = "indent,eol,nostop"
vim.opt.completeopt = ({"menu", "menuone", "noselect"})
vim.opt.complete:append('k')
vim.opt.shortmess:append('c')
vim.opt.completeopt:append('preview')
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.winborder = 'rounded'
vim.opt.laststatus = 3
local patterns = {
    "*/.git/*",
    "*/.DS_Store",
    "*/node_modules/*",
    "*.o",
    "*.obj",
    "__pycache__",
    "*.pyc",
    "*share/nvim/runtime/colors/*",
}
local wildignore = vim.opt.wildignore:get()
for _, pattern in ipairs(patterns) do
    if not vim.tbl_contains(wildignore, pattern) then
        table.insert(wildignore, pattern)
    end
end
vim.opt.wildignore = wildignore
vim.opt.fillchars = { eob = " " }
vim.opt.textwidth = 100
vim.opt.colorcolumn = '+1'
vim.opt.path:append '**'

vim.opt.cmdheight = 0
vim.opt.spelllang = { "pl" }
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.grepprg = "rg --vimgrep -uu"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.showmatch = true
vim.opt.matchtime = 2
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.showmode = false
vim.opt.pumheight = 10
vim.opt.pumblend = 10
vim.opt.winblend = 0
vim.opt.conceallevel = 0
vim.opt.concealcursor = ""
vim.opt.lazyredraw = false
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000
vim.opt.synmaxcol = 300
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 0
vim.opt.autoread = true
vim.opt.autowrite = false
vim.opt.diffopt:append("vertical")
vim.opt.diffopt:append("algorithm:patience")
vim.opt.diffopt:append("linematch:60")
local undodir = "~/.local/share/nvim/undodir"
vim.opt.undodir = vim.fn.expand(undodir)
local undodir_path = vim.fn.expand(undodir)
if vim.fn.isdirectory(undodir_path) == 0 then
    vim.fn.mkdir(undodir_path, "p")
end
vim.opt.errorbells = false
vim.opt.iskeyword:append("-,_,*")
vim.opt.path:append("**")
vim.opt.selection = "inclusive"
vim.opt.mouse = "a"
vim.opt.modifiable = true
vim.opt.encoding = "UTF-8"
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignorecase = true
vim.opt.foldmethod = "manual"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
if vim.loop.os_uname().sysname == 'OpenBSD' then
    -- OpenBSD
    vim.opt.clipboard = 'unnamedplus'
else
    vim.opt.clipboard = ({'unnamed', 'unnamedplus'})  -- use the clipboard as the unnamed register
end
if os.getenv 'SSH_CLIENT' ~= nil then
    vim.opt.clipboard = 'unnamedplus'
    vim.g.clipboard = {
        name = 'OSC 52',
        copy = {
            ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
        },
        paste = {
            ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
        },
    }
end
