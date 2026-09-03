return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = false },
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      window = {
        mappings = {
          ["l"] = "open",
          ["h"] = "close_node",
          ["P"] = { "toggle_preview", config = { use_float = true } },
        },
      },
    },
  },
  {
    "nvim-mini/mini.files",
    opts = {
      options = { use_as_default_explorer = false },
      windows = { preview = true, width_focus = 32, width_nofocus = 18, width_preview = 40 },
    },
  },
  {
    "stevearc/oil.nvim",
    cmd = { "Oil" },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Oil: current file directory" },
      { "<leader>fo", "<cmd>Oil --float<cr>", desc = "Oil (floating)" },
    },
    opts = {
      default_file_explorer = false,
      columns = { "icon", "permissions", "size", "mtime" },
      view_options = { show_hidden = true, natural_order = true },
      float = { border = "rounded", max_width = 100, max_height = 30 },
      keymaps = {
        ["<C-p>"] = "actions.preview",
        ["q"] = "actions.close",
        ["g."] = "actions.toggle_hidden",
      },
    },
  },
}
