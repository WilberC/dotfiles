return {
  {
    "Gentleman-Programming/gentleman-kanagawa-blur",
    name = "gentleman-kanagawa-blur",
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "gentleman-kanagawa-blur" },
  },
  {
    "folke/which-key.nvim",
    opts = { preset = "classic", win = { border = "rounded" } },
  },
  {
    "b0o/incline.nvim",
    event = "BufReadPre",
    opts = { hide = { cursorline = true }, window = { margin = { vertical = 0, horizontal = 1 } } },
  },
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    dependencies = { "folke/twilight.nvim" },
    keys = { { "<leader>uz", "<cmd>ZenMode<cr>", desc = "Toggle Zen Mode" } },
    opts = { plugins = { gitsigns = true, tmux = false, twilight = { enabled = true } } },
  },
  {
    "folke/twilight.nvim",
    cmd = "Twilight",
    keys = { { "<leader>uT", "<cmd>Twilight<cr>", desc = "Toggle Twilight" } },
    opts = {},
  },
}
