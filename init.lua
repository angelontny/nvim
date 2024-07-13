-- Custom neovim config inspired by kickstart.nvim

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

options = {
  number = true,
  relativenumber = true,
  mouse = 'a',
  showmode = false,
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
    'numToStr/Comment.nvim', -- gc to comment out selected lines
    'lewis6991/gitsigns.nvim', -- gitsigns

    { -- Useful plugin to show you pending keybinds.
      'folke/which-key.nvim',
      event = 'VimEnter', -- Sets the loading event to 'VimEnter'
      config = function() -- This is the function that runs, AFTER loading
        require('which-key').setup()

        -- Document existing key chains
        require('which-key').register {
          { "<leader>c", group = "[C]ode" },
          { "<leader>c_", hidden = true },
          { "<leader>d", group = "[D]ocument" },
          { "<leader>d_", hidden = true },
          { "<leader>h", group = "Git [H]unk" },
          { "<leader>h_", hidden = true },
          { "<leader>r", group = "[R]ename" },
          { "<leader>r_", hidden = true },
          { "<leader>s", group = "[S]earch" },
          { "<leader>s_", hidden = true },
          { "<leader>t", group = "[T]oggle" },
          { "<leader>t_", hidden = true },
          { "<leader>w", group = "[W]orkspace" },
          { "<leader>w_", hidden = true },
        }
        -- visual mode
        require('which-key').register{
          { "<leader>h", desc = "Git [H]unk", mode = "v" },
        }
      end,
    },

    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },

    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      config = function(_)
        hour = tonumber(os.date("%H"))
        if hour >= 9 and hour <= 17 then
          vim.cmd.colorscheme("tokyonight-day")
        else
          require("tokyonight").setup({transparent = true})
          vim.cmd.colorscheme("tokyonight-storm")
        end
      end,
    },
},

  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "tokyonight-storm" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
