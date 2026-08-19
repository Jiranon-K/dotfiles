return {
  -- ── ปิดวงเล็บ/ญาติให้อัตโนมัติ ───────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { check_ts = true, fast_wrap = {} },
  },

  -- ── ครอบ/เปลี่ยน/ลบ วงเล็บ-เครื่องหมายคำพูด ──────────
  -- ตัวอย่าง: ysiw" ครอบคำด้วย "  ·  cs"' เปลี่ยน " เป็น '  ·  ds" ลบ "
  {
    "kylechui/nvim-surround",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- ── กระโดดไปที่ไหนก็ได้ในจอ (กด s แล้วพิมพ์ 2 ตัวอักษร) ─
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = { modes = { char = { enabled = false } } },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "󰉁 กระโดดไปตำแหน่ง" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "󰉁 เลือกทั้งบล็อก" },
    },
  },

  -- ── ไฮไลต์ TODO / FIXME / HACK ในโค้ด ────────────────
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = true },
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "󰄬 หา TODO ทั้งหมด" },
      { "<leader>xt", "<cmd>TodoTrouble<cr>",   desc = "󰄬 TODO ในรายการ" },
    },
  },

  -- ── หน้าต่างรวม error / อ้างอิง สวย ๆ ─────────────────
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = { focus = true, warn_no_results = false, open_no_results = true },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "󰅚 error ทั้งโปรเจกต์" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "󰅚 error ไฟล์นี้" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<cr>",                  desc = "󰎠 โครงสร้างไฟล์" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                   desc = "󰁨 quickfix" },
    },
  },

  -- ── terminal ลอย ๆ ในตัว nvim ────────────────────────
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    opts = {
      open_mapping = [[<C-\>]],
      direction = "float",
      shade_terminals = false,
      float_opts = { border = "rounded", winblend = 0 },
      size = function(term)
        if term.direction == "horizontal" then return 15 end
        if term.direction == "vertical" then return vim.o.columns * 0.4 end
      end,
    },
    keys = {
      { "<C-\\>",     "<cmd>ToggleTerm<cr>",                   mode = { "n", "t" }, desc = " terminal ลอย" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>",   desc = " terminal ลอย" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = " terminal ล่างจอ" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>",   desc = " terminal ข้างจอ" },
    },
  },
}
