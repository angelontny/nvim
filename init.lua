-- Custom neovim config inspired by kickstart.nvim

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

local options = {
  number = true,
  relativenumber = true,
  mouse = 'a',
  showmode = true,
  clipboard = 'unnamedplus',
  breakindent = true,
  undofile = true,
  ignorecase = true,
  smartcase = true,
  signcolumn = 'yes',
  updatetime = 250,
  -- Decrease mapped sequence wait time,
  -- Displays which-key popup sooner,
  timeoutlen = 500,
  -- Configure how new splits should be opened,
  splitright = true,
  splitbelow = false,
  -- Sets how neovim will display certain whitespace characters in the editor.,
  --  See `:help 'list'`,
  --  and `:help 'listchars'`,
  list = true,
  listchars = { tab = '» ', trail = '·', nbsp = '␣' },
  -- Preview substitutions live, as you type!,
  inccommand = 'split',
  -- Show which line your cursor is on,
  cursorline = true,
  -- Minimal number of screen lines to keep above and below the cursor.,
  scrolloff = 10,
  -- Set highlight on search, but clear on pressing <Esc> in normal mode,
  hlsearch = true
}

for key, value in pairs(options) do
  vim.opt[key] = value
end

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Terminal Mode?
-- vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Use CTRL+<hjkl> to move between windows
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Add keymap for miniFiles
vim.keymap.set('n', '<leader>pv', function () return MiniFiles.open(vim.api.nvim_buf_get_name(0), false) end, { desc = 'Open MiniFiles' })


-- Autocommand
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})


-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add your plugins here
    'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
    { 'numToStr/Comment.nvim', opts = { } }, -- gc to comment out selected lines
    { 'lewis6991/gitsigns.nvim', opts = { } }, -- gitsigns

    { -- Useful plugin to show you pending keybinds.
      'folke/which-key.nvim',
      event = 'VimEnter', -- Sets the loading event to 'VimEnter'
      config = function() -- This is the function that runs, AFTER loading
        local whichKey = require('which-key')
        whichKey.setup()

        -- Document existing key chains
        whichKey.add {
          { "", group = "[T]oggle" },
          { "", group = "Git [H]unk" },
          { "", desc = "<leader>d_", hidden = true },
          { "", desc = "<leader>h_", hidden = true },
          { "", desc = "<leader>r_", hidden = true },
          { "", group = "[R]ename" },
          { "", group = "[S]earch" },
          { "", group = "[D]ocument" },
          { "", group = "[C]ode" },
          { "", desc = "<leader>t_", hidden = true },
          { "", desc = "<leader>c_", hidden = true },
          { "", group = "[W]orkspace" },
          { "", desc = "<leader>w_", hidden = true },
          { "", desc = "<leader>s_", hidden = true },
        }
        -- visual mode
        whichKey.add {
          { "", desc = "<leader>h", mode = "v" }
        }
      end,
    },

    -- Eye candy
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },

    {
      "folke/tokyonight.nvim", lazy = false, priority = 1000, config = function(_)
        local hour = tonumber(os.date("%H"))
        if hour >= 17 or hour < 8 then
          require("tokyonight").setup({transparent = true})
          vim.cmd.colorscheme("tokyonight-night")
        end
      end,
    },

    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
      config = function(_)
        local hour = tonumber(os.date("%H"))
        if hour >= 9 and hour < 17 then
          require('catppuccin').setup({})
          vim.cmd.colorscheme('catppuccin-latte')
        end
      end,
    },
    -- Smooth scrolling
    {
      "karb94/neoscroll.nvim",
      opts = {
        easing = 'quadratic',
      },
      config = function ()
        -- Add keymap
        local neoscroll = require 'neoscroll'
        vim.keymap.set('n', '<leader>u', function() neoscroll.ctrl_u({ duration = 250, easing = 'circular'}) end, { desc = 'Scroll Up' })
        vim.keymap.set('n', '<leader>d', function() neoscroll.ctrl_d({ duration = 250, easing = 'circular'}) end, { desc = 'Scroll Down' })
        vim.keymap.set('n', '<leader>f', function() neoscroll.ctrl_f({ duration = 350, easing = 'circular'}) end, { desc = 'Scroll Backwards' })
        vim.keymap.set('n', '<leader>b', function() neoscroll.ctrl_b({ duration = 350, easing = 'circular'}) end, { desc = 'Scroll Forwards' })
      end,
    },

    -- Treesitter
    { 'nvim-treesitter/nvim-treesitter',
      build = ":TSUpdate",
      config = function(_)
        require('nvim-treesitter.configs').setup {
          -- A list of parser names, or "all" (the listed parsers MUST always be installed)
          ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "nix", "cpp" }, -- "latex" requires treesitter-cli

          -- Install parsers synchronously (only applied to `ensure_installed`)
          sync_install = false,

          -- Automatically install missing parsers when entering buffer
          -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
          auto_install = false,

          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
        }
      end,
    },

    -- mini.nvim
    { -- Collection of various small independent plugins/modules
      'echasnovski/mini.nvim',
      config = function()
        ---@diagnostic disable-next-line: duplicate-set-field
        local statusLine = require 'mini.statusline'
        statusLine.setup({ })
        statusLine.section_location = function()
          return '%2l:%-2v'
        end

        require('mini.files').setup({
          windows = {
            preview = true,
            width_preview = 80
          }
        })
      end,
    },

    --LSP configuration ( convenience was the priority here, but mason won't work on nixos )
    --Turns out, it takes a lot of time on nixos
    {
      "neovim/nvim-lspconfig",
      config = function(_)
        local lspconfig = require 'lspconfig'
        lspconfig.ltex.setup({})
      end,
    },
},

  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "tokyonight-storm" } },
  -- automatically check for plugin updates
  checker = { enabled = false },
})
