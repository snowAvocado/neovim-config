-----------------------------------------------------------
-- Lazy.nvim bootstrap
-----------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-----------------------------------------------------------
-- Plugins
-----------------------------------------------------------
local plugins = {

  -- Theme
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Telescope
  { "nvim-telescope/telescope.nvim", tag = "0.1.6", dependencies = { "nvim-lua/plenary.nvim" } },

  -- LSP + Mason
  "neovim/nvim-lspconfig",
  "mason-org/mason.nvim",
  "mason-org/mason-lspconfig.nvim",

  -- Autocompletion
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "L3MON4D3/LuaSnip",

  -- File Explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
  },

  -- Statusline
  "nvim-lualine/lualine.nvim",

  -- Git
  "lewis6991/gitsigns.nvim",
}

require("lazy").setup(plugins, {})

-----------------------------------------------------------
-- Theme Setup
----------------------------------------------------------
--[[
require("catppuccin").setup({
    flavour = "auto", -- latte, frappe, macchiato, mocha
    background = { -- :h background
        light = "latte",
        dark = "mocha",
    },
    transparent_background = false, -- disables setting the background color.
    float = {
        transparent = false, -- enable transparent floating windows
        solid = false, -- use solid styling for floating windows, see |winborder|
    },
    show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
    term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
    dim_inactive = {
        enabled = false, -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15, -- percentage of the shade to apply to the inactive window
    },
    no_italic = false, -- Force no italic
    no_bold = false, -- Force no bold
    no_underline = false, -- Force no underline
    styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" }, -- Change the style of comments
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
    },
    lsp_styles = { -- Handles the style of specific lsp hl groups (see `:h lsp-highlight`).
        virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
            ok = { "italic" },
        },
        underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
            ok = { "underline" },
        },
        inlay_hints = {
            background = true,
        },
    },
    color_overrides = {},
    custom_highlights = {},
    default_integrations = true,
    auto_integrations = false,
    integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        notify = false,
        mini = {
            enabled = true,
            indentscope_color = "",
        },
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
    },
})

-- setup must be called before loading
vim.cmd.colorscheme "catppuccin"
-- vim.cmd.colorscheme("catppuccin-latte")
]]
-----------------------------------------------------------
-- Basic Vim Options
-----------------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.cursorline = true
vim.g.mapleader = " "

-----------------------------------------------------------
-- Treesitter Setup
-----------------------------------------------------------
require("nvim-treesitter.configs").setup({
  ensure_installed = { "lua", "javascript", "python", "go", "bash", "cpp", "rust" },
  highlight = { enable = true },
  indent = { enable = true },
})

-----------------------------------------------------------
-- Telescope Keymaps
-----------------------------------------------------------
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files)
vim.keymap.set("n", "<leader>fg", builtin.live_grep)

-----------------------------------------------------------
-- Mason + LSP Setup
-----------------------------------------------------------

-- Mason setup
require("mason").setup()
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
  ensure_installed = {
    "lua_ls",          -- Lua
--   "tsserver",        -- TypeScript/JavaScript
    "pylsp",         -- Python
    "clangd",          -- C/C++
    "rust_analyzer",   -- Cargo
    -- "gopls",           -- Go
  --  "buildifier"       -- Bazel formatter/LSP
  },
})

-- Capabilities for nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require("lspconfig")


for _, server in ipairs(mason_lspconfig.get_installed_servers()) do
vim.lsp.config(server, {
  capabilities = capabilities,
  root_markers = { '.git' },
  on_attach = function(client, bufnr)
      local opts = { noremap = true, silent = true }
      vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  end,
})


end
-----------------------------------------------------------
-- nvim-cmp Completion Setup
-----------------------------------------------------------
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  },
})

-----------------------------------------------------------
-- Neo-tree Setup
-----------------------------------------------------------
require("neo-tree").setup({
  close_if_last_window = true,
})
vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>")

-----------------------------------------------------------
-- Lualine Setup
-----------------------------------------------------------
require("lualine").setup({
 options = { theme = "catppuccin" },
})

-----------------------------------------------------------
-- Gitsigns Setup
-----------------------------------------------------------
require("gitsigns").setup()


-- custom keys
-----------------------------------------------------------
-- Cargo Custom Commands + Keymaps
-----------------------------------------------------------
-- Create user commands for Cargo development
vim.api.nvim_create_user_command("CargoBuild", function()
  vim.cmd("!cargo build")
end, {})

vim.api.nvim_create_user_command("CargoRun", function()
  vim.cmd("!cargo run")
end, {})

vim.api.nvim_create_user_command("CargoTest", function()
  vim.cmd("!cargo test")
end, {})

vim.api.nvim_create_user_command("CargoFmt", function()
  vim.cmd("!cargo fmt")
end, {})

vim.api.nvim_create_user_command("CargoClippy", function()
  vim.cmd("!cargo clippy")
end, {})

-----------------------------------------------------------
-- Keymaps for Cargo commands
-----------------------------------------------------------
-- <leader>rb -> build
vim.keymap.set("n", "<leader>cb", ":CargoBuild<CR>", { noremap = true, silent = true })
-- <leader>rr -> run
vim.keymap.set("n", "<leader>cr", ":CargoRun<CR>", { noremap = true, silent = true })
-- <leader>rt -> test
vim.keymap.set("n", "<leader>ct", ":CargoTest<CR>", { noremap = true, silent = true })
-- <leader>rf -> format
vim.keymap.set("n", "<leader>cf", ":CargoFmt<CR>", { noremap = true, silent = true })
-- <leader>rc -> clippy
vim.keymap.set("n", "<leader>cc", ":CargoClippy<CR>", { noremap = true, silent = true })


