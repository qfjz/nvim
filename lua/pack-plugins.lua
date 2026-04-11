vim.pack.add({
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
    { src = 'https://github.com/folke/flash.nvim' },
    { src = 'https://github.com/stevearc/oil.nvim' },
    { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim' },
    { src = "https://github.com/ibhagwan/fzf-lua" },
    { src = "https://github.com/folke/noice.nvim" },
    { src = "https://github.com/NvChad/showkeys" },
    { src = "https://github.com/windwp/nvim-autopairs" },
    { src = "https://github.com/MunifTanjim/nui.nvim" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
    { src = "https://github.com/akinsho/toggleterm.nvim" },
    { src = 'https://github.com/lewis6991/gitsigns.nvim' },
    { src = 'https://github.com/Saghen/blink.cmp', version = 'v1.10.2' },
    { src = 'https://github.com/L3MON4D3/LuaSnip' },
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
    { src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },
    { src = "https://github.com/nvim-lualine/lualine.nvim" },
    { src = "https://github.com/windwp/nvim-autopairs" },
    { src = 'https://github.com/romgrk/barbar.nvim' },
})

-- kolory
vim.pack.add({
    { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
    { src = 'https://github.com/folke/tokyonight.nvim' },
    { src = 'https://github.com/rebelot/kanagawa.nvim' },
    { src = 'https://github.com/rose-pine/neovim', name = 'rose-pine' },
    { src = 'https://github.com/EdenEast/nightfox.nvim' },
    { src = 'https://github.com/neanias/everforest-nvim' },
    { src = 'https://github.com/sainnhe/sonokai' },
    { src = 'https://github.com/AlexvZyl/nordic.nvim' },
    { src = 'https://github.com/ribru17/bamboo.nvim' },
    { src = 'https://github.com/maxmx03/solarized.nvim' },
})

local enable_which_key = vim.env.NVIM_WK == "1"
if enable_which_key then
    vim.pack.add({
        { src = "https://github.com/folke/which-key.nvim" },
    })
    require("which-key").setup()
end
