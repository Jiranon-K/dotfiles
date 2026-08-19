return {
  {
    "saghen/blink.cmp",
    version = "1.*",                 -- ใช้ไบนารีสำเร็จรูป ไม่ต้องลง Rust
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = {
        preset = "super-tab",        -- Tab = เลือก/ยืนยัน, Shift-Tab = ย้อน
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 150,
          window = { border = "rounded", winblend = 0 },
        },
        ghost_text = { enabled = true },   -- โชว์ตัวอย่างจาง ๆ ข้างหน้า
        menu = {
          border = "rounded",
          winblend = 0,
          draw = {
            columns = {
              { "kind_icon", "label", gap = 1 },
              { "kind", "source_name", gap = 1 },
            },
          },
        },
        list = { selection = { preselect = true, auto_insert = false } },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          buffer   = { score_offset = -3 },
          snippets = { score_offset = -1 },
        },
      },
      cmdline = {
        keymap = { preset = "inherit" },
        completion = { menu = { auto_show = true } },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
