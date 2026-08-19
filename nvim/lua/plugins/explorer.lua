return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>fe", "<cmd>Neotree toggle<cr>",              desc = "󰙅 เปิด/ปิดตัวจัดการไฟล์" },
      { "<C-n>",      "<cmd>Neotree toggle<cr>",              desc = "󰙅 เปิด/ปิดตัวจัดการไฟล์" },
      { "<leader>fE", "<cmd>Neotree reveal<cr>",              desc = "󰈞 ชี้ไฟล์ปัจจุบันในต้นไม้" },
      { "<leader>ge", "<cmd>Neotree git_status<cr>",          desc = " ไฟล์ที่ git เปลี่ยน" },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style   = "rounded",
      enable_git_status    = true,
      enable_diagnostics   = true,
      default_component_configs = {
        indent = {
          with_expanders   = true,
          expander_collapsed = "",
          expander_expanded  = "",
          expander_highlight = "NeoTreeExpander",
        },
        icon = { folder_closed = "󰉋", folder_open = "󰝰", folder_empty = "󰉖", default = "󰈔" },
        modified = { symbol = "󰆓" },
        git_status = {
          symbols = {
            added = "", modified = "", deleted = "", renamed = "󰁕",
            untracked = "", ignored = "", unstaged = "󰄱", staged = "", conflict = "",
          },
        },
      },
      window = {
        width = 32,
        mappings = {
          ["<space>"] = "none",       -- ปล่อย space ให้เป็น leader
          ["l"] = "open",
          ["h"] = "close_node",
          ["H"] = "toggle_hidden",
          ["Y"] = "copy_to_clipboard",
        },
      },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = { "node_modules", ".git", ".next", "__pycache__", ".venv" },
        },
      },
    },
  },
}
