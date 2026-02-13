-- ============================================================================
-- CORE SETTINGS
-- ============================================================================

vim.g.mapleader = " "       -- Space as leader key
vim.g.maplocalleader = " "  -- Space as local leader key

-- Ensure Go and Homebrew tools are on PATH
vim.env.PATH = vim.env.HOME .. "/go/bin:/opt/homebrew/bin:" .. vim.env.PATH

local opt = vim.opt

-- Line numbers
opt.number = true           -- Show absolute line number on current line
opt.relativenumber = true   -- Relative numbers on other lines (faster j/k jumps)
opt.signcolumn = "yes"      -- Always show sign column (prevents layout shift)
opt.cursorline = true       -- Highlight the current line
opt.termguicolors = true    -- 24-bit color support

-- Indentation (global defaults, overridden per filetype below)
opt.tabstop = 4             -- Tab width
opt.shiftwidth = 4          -- Indent width for >> and <<
opt.expandtab = true        -- Use spaces instead of tabs
opt.smartindent = true      -- Auto-indent new lines based on syntax

-- Display
opt.wrap = false            -- Don't wrap long lines
opt.scrolloff = 8           -- Keep 8 lines visible above/below cursor
opt.sidescrolloff = 8       -- Keep 8 columns visible left/right of cursor
opt.colorcolumn = "80"      -- Show vertical guide at column 80

-- Search
opt.ignorecase = true       -- Case-insensitive search...
opt.smartcase = true         -- ...unless query contains uppercase
opt.hlsearch = true         -- Highlight all matches
opt.incsearch = true        -- Show matches as you type

-- Window splits
opt.splitbelow = true       -- Horizontal splits open below
opt.splitright = true       -- Vertical splits open to the right

-- System integration
opt.clipboard = "unnamedplus" -- Use system clipboard for yank/paste
opt.undofile = true          -- Persistent undo across sessions
opt.swapfile = false         -- No swap files
opt.backup = false           -- No backup files

-- Performance / UX
opt.updatetime = 250         -- Faster CursorHold events (used by gitsigns, etc.)
opt.timeoutlen = 300         -- Time to wait for mapped sequence (ms)
opt.completeopt = "menuone,noselect" -- Completion menu behavior
opt.mouse = "a"              -- Enable mouse in all modes

-- ============================================================================
-- FILETYPE OVERRIDES
-- ============================================================================

-- Python: column guide at 88 (ruff/black default)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    vim.opt_local.colorcolumn = "88"
  end,
})

-- Go: use tabs instead of spaces
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = function()
    vim.opt_local.expandtab = false
  end,
})

-- Shell: 2-space indent
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sh", "bash", "zsh" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- Web/config languages: 2-space indent
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml", "yaml.ansible", "json", "lua", "javascript", "typescript", "html", "css", "jinja2" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- ============================================================================
-- AUTOCOMMANDS
-- ============================================================================

-- Strip trailing whitespace on save (preserves cursor position)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, pos)
  end,
})

-- Brief highlight on yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Auto-fix and organize imports on save (Python via ruff LSP)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function(args)
    local client = vim.lsp.get_clients({ bufnr = args.buf, name = "ruff" })[1]
    if not client then return end
    local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
    for _, action in ipairs({ "source.fixAll.ruff", "source.organizeImports.ruff" }) do
      params.context = { only = { action }, diagnostics = {} }
      local result = client.request_sync("textDocument/codeAction", params, 3000, args.buf)
      if result and result.result and result.result[1] then
        vim.lsp.util.apply_workspace_edit(result.result[1].edit, client.offset_encoding)
      end
    end
  end,
})

-- Format on save using LSP (applies to all filetypes with an LSP formatter)
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    vim.lsp.buf.format({ async = false, timeout_ms = 3000 })
  end,
})

-- ============================================================================
-- INLINE DIAGNOSTICS
-- ============================================================================

vim.diagnostic.config({
  virtual_text = {
    spacing = 4,
    prefix = "●",            -- Dot prefix for inline diagnostics
  },
  signs = true,              -- Show signs in the sign column
  underline = true,          -- Underline diagnostic text
  update_in_insert = true,   -- Update diagnostics while typing
  severity_sort = true,      -- Show most severe diagnostics first
  float = {
    border = "rounded",
    source = true,           -- Show which LSP produced the diagnostic
  },
})

-- ============================================================================
-- KEYMAPS
-- ============================================================================

local map = vim.keymap.set

-- General
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

-- Window navigation (Ctrl + hjkl)
map("n", "<C-h>", "<C-w>h", { desc = "Focus left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus below window" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus above window" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right window" })

-- Window resizing (Ctrl + arrow keys)
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Buffer navigation (Shift + hl)
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Move selected lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered when scrolling/searching
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev search result (centered)" })

-- Paste over selection without overwriting register
map("x", "<leader>p", [["_dP]], { desc = "Paste without losing register" })

-- Quickfix list navigation
map("n", "<leader>cn", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
map("n", "<leader>cp", "<cmd>cprev<CR>zz", { desc = "Prev quickfix item" })

-- Run current file in toggleterm (filetype-aware)
local run_cmds = {
  python = "uv run %",
  go = "go run %",
  sh = "bash %",
  bash = "bash %",
  lua = "lua %",
  javascript = "node %",
  typescript = "npx tsx %",
}

map("n", "<leader>r", function()
  local ft = vim.bo.filetype
  local cmd = run_cmds[ft]
  if not cmd then
    vim.notify("No run command for filetype: " .. ft, vim.log.levels.WARN)
    return
  end
  cmd = cmd:gsub("%%", vim.fn.expand("%:p"))
  vim.cmd("TermExec cmd=" .. vim.fn.shellescape(cmd))
end, { desc = "Run current file" })

-- ============================================================================
-- PLUGIN MANAGER (lazy.nvim)
-- ============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  -- ========================================================================
  -- COLORSCHEME
  -- ========================================================================
  {
    "folke/tokyonight.nvim",
    lazy = false,              -- Load immediately (before other plugins)
    priority = 1000,           -- Ensure it loads first
    config = function()
      vim.cmd.colorscheme("tokyonight-night")
      -- Make the column guide more visible than the default
      vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#292e42" })
    end,
  },

  -- ========================================================================
  -- UI
  -- ========================================================================

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "tokyonight" },
      })
    end,
  },

  -- Git gutter signs and hunk operations
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          map("n", "]h", gs.next_hunk, { buffer = bufnr, desc = "Next git hunk" })
          map("n", "[h", gs.prev_hunk, { buffer = bufnr, desc = "Prev git hunk" })
          map("n", "<leader>hp", gs.preview_hunk, { buffer = bufnr, desc = "Preview hunk" })
          map("n", "<leader>hr", gs.reset_hunk, { buffer = bufnr, desc = "Reset hunk" })
          map("n", "<leader>hb", gs.blame_line, { buffer = bufnr, desc = "Blame line" })
        end,
      })
    end,
  },

  -- Indent guide lines
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup()
    end,
  },

  -- ========================================================================
  -- NAVIGATION
  -- ========================================================================

  -- Fuzzy finder (files, grep, buffers, diagnostics)
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = { prompt_position = "top" },
          sorting_strategy = "ascending",
        },
      })
      telescope.load_extension("fzf")

      local builtin = require("telescope.builtin")
      map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      map("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      map("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      map("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
      map("n", "<leader>fs", builtin.grep_string, { desc = "Grep string under cursor" })
      map("n", "<leader>fd", builtin.diagnostics, { desc = "Find diagnostics" })
      map("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
    end,
  },

  -- File tree sidebar
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      vim.g.loaded_netrw = 1          -- Disable built-in file explorer
      vim.g.loaded_netrwPlugin = 1
      require("nvim-tree").setup({
        view = { width = 30 },
        filters = { dotfiles = false }, -- Show dotfiles
      })
      map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })
    end,
  },

  -- ========================================================================
  -- LSP (Language Server Protocol)
  --
  -- Architecture:
  --   mason.nvim        -> installs LSP servers
  --   mason-lspconfig   -> bridges mason <-> nvim built-in LSP
  --   nvim-lspconfig    -> provides server cmd/filetype/root definitions
  --   cmp-nvim-lsp      -> advertises completion capabilities to servers
  --
  -- Servers configured:
  --   Python:     ruff (lint/format) + ty (type checking/hover)
  --   Go:         gopls
  --   Lua:        lua_ls
  --   Bash:       bashls (+ shellcheck)
  --   Terraform:  terraformls
  --   Ansible:    ansiblels
  -- ========================================================================
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "ruff", "gopls", "lua_ls" },
        automatic_enable = {
          exclude = { "pylsp" }, -- We use ruff + ty instead
        },
      })
    end,
  },

  {
    "hrsh7th/cmp-nvim-lsp",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",        -- Provides cmd/filetype defs for servers
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- LSP keymaps + per-server tweaks (applied per-buffer when an LSP attaches)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local opts = function(desc) return { buffer = bufnr, desc = desc } end
          map("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))
          map("n", "gr", vim.lsp.buf.references, opts("Go to references"))
          map("n", "gi", vim.lsp.buf.implementation, opts("Go to implementation"))
          map("n", "K", vim.lsp.buf.hover, opts("Hover documentation"))
          map("n", "<leader>cr", vim.lsp.buf.rename, opts("Rename symbol"))
          map("n", "<leader>ca", vim.lsp.buf.code_action, opts("Code action"))
          map("n", "<leader>F", function() vim.lsp.buf.format({ async = true }) end, opts("Format document"))
          map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, opts("Next diagnostic"))
          map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, opts("Prev diagnostic"))
          map("n", "<leader>d", vim.diagnostic.open_float, opts("Show diagnostic float"))
          -- Disable hover from ruff (ty provides it)
          if client and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end
        end,
      })

      -- Python: ruff for linting + formatting
      vim.lsp.config("ruff", {
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
        capabilities = capabilities,
      })

      -- Python: ty for type checking, hover, completions, go-to-definition
      vim.lsp.config("ty", {
        filetypes = { "python" },
        root_markers = { "pyproject.toml", ".git" },
        capabilities = capabilities,
      })

      vim.lsp.enable("ruff")
      vim.lsp.enable("ty")

      -- Go
      vim.lsp.config("gopls", {
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_markers = { "go.work", "go.mod", ".git" },
        capabilities = capabilities,
        settings = {
          gopls = {
            analyses = { unusedparams = true, shadow = true },
            staticcheck = true,
            gofumpt = true,
          },
        },
      })

      -- Lua (configured for Neovim development)
      vim.lsp.config("lua_ls", {
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luacheckrc", ".git" },
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },  -- Recognize vim global
            workspace = {
              library = { vim.env.VIMRUNTIME },      -- Neovim runtime for completions
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      })

      -- Bash (uses shellcheck for linting)
      vim.lsp.config("bashls", {
        filetypes = { "sh", "bash", "zsh" },
        root_markers = { ".git" },
        capabilities = capabilities,
        settings = {
          bashIde = {
            shellcheckPath = "shellcheck",
          },
        },
      })
      vim.lsp.enable("bashls")

      -- Terraform
      vim.lsp.config("terraformls", {
        filetypes = { "terraform", "terraform-vars", "hcl" },
        root_markers = { ".terraform", "*.tf", ".git" },
        capabilities = capabilities,
      })
      vim.lsp.enable("terraformls")

      -- Ansible
      vim.lsp.config("ansiblels", {
        filetypes = { "yaml.ansible" },
        root_markers = { "ansible.cfg", "playbooks", "roles", ".git" },
        capabilities = capabilities,
        settings = {
          ansible = {
            validation = { lint = { enabled = true, path = "ansible-lint" } },
          },
        },
      })
      vim.lsp.enable("ansiblels")
    end,
  },

  -- ========================================================================
  -- AUTOCOMPLETION
  --
  -- Tab priority: Copilot suggestion > cmp menu > snippet jump > indent
  -- ========================================================================
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",   -- LSP completions
      "hrsh7th/cmp-buffer",     -- Words from current buffer
      "hrsh7th/cmp-path",       -- Filesystem paths
      "L3MON4D3/LuaSnip",       -- Snippet engine
      "saadparwaiz1/cmp_luasnip", -- Snippet completions
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),   -- Manually trigger completion
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if vim.fn["copilot#GetDisplayedSuggestion"]().text ~= "" then
              vim.api.nvim_feedkeys(vim.fn["copilot#Accept"](), "n", false)
            elseif cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },  -- LSP (highest priority)
          { name = "luasnip" },   -- Snippets
          { name = "path" },      -- File paths
        }, {
          { name = "buffer" },    -- Buffer words (fallback)
        }),
      })
    end,
  },

  -- ========================================================================
  -- TREESITTER (syntax highlighting + indentation)
  --
  -- Treesitter provides AST-based highlighting (more accurate than regex).
  -- Parsers are installed per-language; highlight/indent are enabled via
  -- Neovim's built-in treesitter APIs (not the plugin's old module system).
  -- ========================================================================
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",       -- Auto-update parsers on plugin update
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "python", "go", "gomod", "gosum", "gotmpl",
          "bash", "lua", "vim", "vimdoc",
          "json", "yaml", "toml", "dockerfile",
          "hcl", "markdown", "markdown_inline",
          "javascript", "typescript", "html", "css",
          "jinja2", "sql", "comment",
        },
      })
      -- Enable treesitter highlight and indent per buffer when a parser exists
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          if vim.treesitter.get_parser(0, nil, { error = false }) then
            vim.treesitter.start()
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  -- ========================================================================
  -- COPILOT (AI ghost text suggestions)
  --
  -- Tab is handled in nvim-cmp config above (Copilot > cmp > snippet)
  -- ========================================================================
  {
    "github/copilot.vim",
    cmd = { "Copilot" },
    event = "InsertEnter",     -- Load when entering insert mode
    config = function()
      vim.g.copilot_no_tab_map = true  -- We handle Tab in cmp config
      vim.keymap.set("i", "<C-]>", "<Plug>(copilot-dismiss)", { desc = "Dismiss Copilot" })
      vim.keymap.set("i", "<M-]>", "<Plug>(copilot-next)", { desc = "Next Copilot suggestion" })
      vim.keymap.set("i", "<M-[>", "<Plug>(copilot-previous)", { desc = "Prev Copilot suggestion" })
    end,
  },

  -- ========================================================================
  -- CODE ACTIONS LIGHTBULB
  -- ========================================================================
  {
    "kosayoda/nvim-lightbulb",
    event = "LspAttach",       -- Only load when an LSP server attaches
    config = function()
      require("nvim-lightbulb").setup({
        autocmd = { enabled = true },
        sign = { enabled = true, text = "💡" },
        virtual_text = { enabled = false },
      })
    end,
  },

  -- ========================================================================
  -- EDITING
  -- ========================================================================

  -- Auto-close brackets and quotes
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  -- Surround text objects: cs'" (change ' to "), ysiw) (surround word with ())
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = true,
  },

  -- Toggle comments: gcc (line), gc (visual selection)
  { "numToStr/Comment.nvim", config = true },

  -- ========================================================================
  -- WHICH-KEY (keybinding hints popup)
  --
  -- Press <leader> and wait 300ms to see available keybindings.
  -- Groups organize related keymaps under a common prefix.
  -- ========================================================================
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        delay = 300,               -- Show popup after 300ms
        icons = { mappings = false },
      })
      wk.add({
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code/quickfix" },
        { "<leader>d", desc = "Show diagnostic" },
        { "<leader>e", desc = "Toggle file tree" },
        { "<leader>f", group = "find (telescope)" },
        { "<leader>h", group = "git hunk" },
        { "<leader>r", desc = "Run current file" },
        { "<leader>F", desc = "Format document" },
        { "<leader>w", desc = "Save file" },
        { "<leader>q", desc = "Quit" },
      })
    end,
  },

  -- ========================================================================
  -- GO-SPECIFIC (extra tooling beyond gopls)
  -- ========================================================================
  {
    "ray-x/go.nvim",
    dependencies = { "ray-x/guihua.lua", "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("go").setup()
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
  },

  -- ========================================================================
  -- TOGGLETERM (persistent toggleable terminal panel)
  --
  -- Ctrl-\ toggles the terminal on/off (like VS Code's integrated terminal).
  -- <leader>r runs the current file in it.
  -- Inside the terminal: Esc exits terminal mode, Ctrl-\ closes it.
  -- ========================================================================
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "TermExec", "ToggleTerm" },  -- Lazy-load on these commands
    keys = {
      { "<C-\\>", desc = "Toggle terminal" },
    },
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<C-\>]],
        direction = "horizontal",
        size = 15,
        shade_terminals = true,
        start_in_insert = true,
        close_on_exit = false,     -- Keep terminal open after command finishes
      })
      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "term://*toggleterm#*",
        callback = function()
          local opts = { buffer = 0 }
          vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)     -- Exit terminal mode
          vim.keymap.set("t", "<C-\\>", [[<Cmd>ToggleTerm<CR>]], opts) -- Close terminal
        end,
      })
    end,
  },

  -- ========================================================================
  -- ANSIBLE (filetype detection + syntax for yaml.ansible)
  -- ========================================================================
  {
    "pearofducks/ansible-vim",
    ft = { "yaml.ansible" },
  },

}, {
  -- lazy.nvim options
  checker = { enabled = false },        -- Don't auto-check for plugin updates
  change_detection = { notify = false }, -- Don't notify on config file changes
})
