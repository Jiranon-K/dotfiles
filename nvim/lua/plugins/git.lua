return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      current_line_blame = false,
      current_line_blame_opts = { delay = 400, virt_text_pos = "eol" },
      preview_config = { border = "rounded" },
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end
        map("n", "]h", function() gs.nav_hunk("next") end, " เปลี่ยนแปลงถัดไป")
        map("n", "[h", function() gs.nav_hunk("prev") end, " เปลี่ยนแปลงก่อนหน้า")
        map("n", "<leader>gp", gs.preview_hunk_inline, " ดูว่าเปลี่ยนอะไร")
        map("n", "<leader>gr", gs.reset_hunk,          " ย้อนการเปลี่ยนตรงนี้")
        map("n", "<leader>gR", gs.reset_buffer,        " ย้อนทั้งไฟล์")
        map("n", "<leader>ga", gs.stage_hunk,          " stage ตรงนี้")
        map("n", "<leader>gA", gs.stage_buffer,        " stage ทั้งไฟล์")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, " ใครแก้บรรทัดนี้")
        map("n", "<leader>gB", gs.toggle_current_line_blame, " เปิด/ปิด blame ตลอดเวลา")
        map("n", "<leader>gd", gs.diffthis,            " เทียบกับ git")
      end,
    },
  },
}
