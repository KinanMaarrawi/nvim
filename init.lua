-- silence only the lspconfig deprecation notice
local _notify, _notify_once = vim.notify, vim.notify_once
local function _silence(msg)
  return type(msg) == "string"
      and (msg:match("require%('lspconfig'%)") or msg:match("use vim%.lsp%.config"))
end
vim.notify = function(msg, level, opts)
  if _silence(msg) then return end
  return _notify(msg, level, opts)
end
vim.notify_once = function(msg, level, opts)
  if _silence(msg) then return end
  return _notify_once(msg, level, opts)
end

-- ====== Core options (no bloat) ======
vim.o.scrolloff = 999
vim.o.sidescrolloff = 8
vim.o.cursorline = true
vim.g.mapleader = " "
vim.o.termguicolors = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.clipboard = "unnamedplus"
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.swapfile = false
vim.o.undofile = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.smartindent = true
vim.o.splitright = true
vim.o.splitbelow = true
local map = vim.keymap.set
map("n", "<leader>w", "<cmd>w<cr>", { desc = "save" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "quit" })
map("n", "<leader>/", "<cmd>nohlsearch<cr>", { desc = "clear search" })
map("n", "<leader>g", "<cmd>LazyGit<cr>", { desc = "open lazygit" })
map("n", "<F2>", "<cmd>w<cr><cmd>bd<cr>", { desc = "save and close file" })
map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "toggle file explorer" })
map("n", "<C-w>", "<C-w>w", { noremap = true })

-- ====== Bootstrap lazy.nvim ======
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- ====== Plugins (strictly minimal) ======
require("lazy").setup({
  -- visuals
  { "catppuccin/nvim",                 name = "catppuccin", priority = 1000 },
  { "nvim-lualine/lualine.nvim" },
  { "nvim-tree/nvim-web-devicons" }, -- tiny, for nice icons (optional but pretty)

  -- file explorer tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
    end,
  },

  -- syntax
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- LSP + completion
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "l3mon4d3/luasnip" },
  { "saadparwaiz1/cmp_luasnip" },

  -- format on save
  { "stevearc/conform.nvim" },

  -- LazyGit
  { "kdheepak/lazygit.nvim", cmd = "LazyGit", dependencies = { "nvim-lua/plenary.nvim" } },
})

-- ====== theme + statusline ======
vim.cmd.colorscheme("catppuccin")
require("lualine").setup({ options = { theme = "catppuccin" } })

-- ====== treesitter ======
require("nvim-treesitter.configs").setup({
  ensure_installed = { "lua", "vim", "bash", "python", "javascript", "typescript", "json", "html", "css", "markdown", "c", "cpp" },
  highlight = { enable = true },
  indent = { enable = true },
})


-- ====== Completion (nvim-cmp) ======
local cmp = require("cmp")
local luasnip = require("luasnip")
cmp.setup({
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"]      = cmp.mapping.confirm({ select = true }),
    ["<Tab>"]     = function(fb)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fb()
      end
    end,
    ["<S-Tab>"]   = function(fb)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fb()
      end
    end,
  }),
  sources = { { name = "path" }, { name = "buffer" }, { name = "luasnip" } },
})

-- ====== Format on save (Conform) ======
require("conform").setup({
  format_on_save = { timeout_ms = 500, lsp_fallback = true },
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format" },
    javascript = { "prettierd", "prettier" },
    typescript = { "prettierd", "prettier" },
    json = { "prettierd", "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    markdown = { "mdformat" },
    sh = { "shfmt" },
    c = { "clang_format" },
    cpp = { "clang_format" },
  },
})
