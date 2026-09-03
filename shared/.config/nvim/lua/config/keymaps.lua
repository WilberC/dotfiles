-- Keymaps in this file are loaded automatically on LazyVim's VeryLazy event.
vim.keymap.set({ "i", "n", "v" }, "<C-s>", "<cmd>write<cr>", { desc = "Save file" })

-- Keep pane movement inside Neovim. Herdr continues to manage its own panes.
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
