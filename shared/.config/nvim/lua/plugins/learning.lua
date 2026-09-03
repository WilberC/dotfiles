return {
  {
    "ThePrimeagen/vim-be-good",
    cmd = "VimBeGood",
  },
  {
    "NStefan002/screenkey.nvim",
    version = "*",
    cmd = "Screenkey",
    keys = {
      { "<leader>uk", "<cmd>Screenkey<cr>", desc = "Toggle screen keys" },
    },
    opts = {
      win_opts = { border = "rounded" },
    },
  },
}
