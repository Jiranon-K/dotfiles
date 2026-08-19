return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      { "<leader><space>", "<cmd>Telescope find_files<cr>",  desc = "󰈞 หาไฟล์" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>",       desc = "󰈞 หาไฟล์" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",        desc = "󰈬 ค้นหาข้อความทั้งโปรเจกต์" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>",      desc = "󰈬 ค้นหาคำใต้เคอร์เซอร์" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",          desc = "󰓩 ไฟล์ที่เปิดอยู่" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",         desc = "󰄉 ไฟล์ล่าสุด" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",        desc = "󰋖 คู่มือ nvim" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>",          desc = "󰌌 ดูปุ่มลัดทั้งหมด" },
      { "<leader>fc", "<cmd>Telescope colorscheme<cr>",      desc = "󰸌 ลองเปลี่ยนธีม" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "󰎠 ฟังก์ชัน/ตัวแปรในไฟล์นี้" },
      { "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "󰎠 ค้นทั้งโปรเจกต์" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>",      desc = "󰅚 error ทั้งหมด" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>",      desc = " ประวัติ commit" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>",       desc = " สถานะ git" },
    },
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
          prompt_prefix = "󰍉  ",
          selection_caret = "󰅂 ",
          entry_prefix = "  ",
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          winblend = 0,
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            width = 0.9,
            height = 0.85,
          },
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          file_ignore_patterns = {
            "node_modules", "%.git/", "dist/", "build/", "%.next/",
            "__pycache__", "%.venv/", "target/", "%.lock",
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
              ["<Esc>"] = actions.close,
            },
          },
        },
        pickers = {
          find_files = { hidden = true },
          buffers = {
            sort_mru = true,
            mappings = { i = { ["<C-d>"] = actions.delete_buffer } },
          },
        },
        extensions = {
          ["ui-select"] = { require("telescope.themes").get_dropdown() },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")
    end,
  },
}
