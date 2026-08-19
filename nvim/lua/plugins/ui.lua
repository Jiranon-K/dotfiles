return {
  -- ── statusline ─────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      local mode_icon = {
        n = "󰋜", i = "󰏫", v = "󰈈", V = "󰈈", ["\22"] = "󰈈",
        c = "󰘳", s = "󰒅", S = "󰒅", R = "󰛔", t = "", nt = "",
      }
      return {
        options = {
          theme = "catppuccin",
          globalstatus = true,
          component_separators = { left = "", right = "" },
          section_separators   = { left = "", right = "" },
          disabled_filetypes = { statusline = { "alpha", "neo-tree" } },
        },
        sections = {
          lualine_a = {
            { function() return " " .. (mode_icon[vim.fn.mode()] or "󰋜") .. " " end, padding = 0 },
          },
          lualine_b = {
            { "branch", icon = "" },
            { "diff", symbols = { added = " ", modified = " ", removed = " " } },
          },
          lualine_c = {
            { "filename", path = 1, symbols = { modified = " 󰆓", readonly = " 󰌾", unnamed = "ไฟล์ใหม่" } },
            {
              "diagnostics",
              symbols = { error = "󰅚 ", warn = "󰀪 ", hint = "󰌶 ", info = "󰋽 " },
            },
          },
          lualine_x = {
            -- LSP ที่กำลังทำงานกับไฟล์นี้
            {
              function()
                local names = {}
                for _, c in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
                  names[#names + 1] = c.name
                end
                if #names == 0 then return "" end
                return "󰒋 " .. table.concat(names, ", ")
              end,
              color = { fg = "#a6e3a1" },
            },
            { "filetype", icon_only = false },
          },
          lualine_y = { { "progress" } },
          lualine_z = { { "location", padding = { left = 1, right = 1 } } },
        },
        extensions = { "neo-tree", "lazy", "mason", "trouble", "toggleterm" },
      }
    end,
  },

  -- ── แถบไฟล์ด้านบน ───────────────────────────────────
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        mode = "buffers",
        separator_style = "slant",
        always_show_bufferline = false,
        show_buffer_close_icons = true,
        show_close_icon = false,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diag)
          local s = ""
          if diag.error then s = s .. " 󰅚 " .. diag.error end
          if diag.warning then s = s .. " 󰀪 " .. diag.warning end
          return s
        end,
        offsets = {
          { filetype = "neo-tree", text = "󰉋  ไฟล์ในโปรเจกต์", highlight = "Directory", separator = true },
        },
      },
    },
  },

  -- ── UI สวย ๆ: cmdline / ข้อความ / popup ─────────────
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search        = false,
        command_palette      = true,   -- cmdline ลอยกลางจอ
        long_message_to_split = true,
        inc_rename           = false,
        lsp_doc_border       = true,
      },
      cmdline = {
        format = {
          cmdline = { icon = "󰘳" },
          search_down = { icon = "󰍉 " },
          search_up   = { icon = "󰍉 " },
          filter      = { icon = "" },
          lua         = { icon = "󰢱" },
          help        = { icon = "󰋖" },
        },
      },
      routes = {
        -- ซ่อนข้อความน่ารำคาญ "written" ตอนเซฟ
        { filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
        { filter = { event = "msg_show", find = "%d+L, %d+B" },         opts = { skip = true } },
      },
    },
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#1e1e2e",
      timeout = 2500,
      render = "wrapped-compact",
      stages = "fade_in_slide_out",
      max_width = 60,
      icons = { ERROR = "󰅚", WARN = "󰀪", INFO = "󰋽", DEBUG = "󰃤", TRACE = "󰛿" },
    },
  },

  -- ── เส้นบอกระดับการเยื้อง ───────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "▏", tab_char = "▏" },
      scope  = { enabled = true, show_start = false, show_end = false },
      exclude = {
        filetypes = { "help", "alpha", "neo-tree", "trouble", "lazy", "mason", "notify", "toggleterm" },
      },
    },
  },

  -- ── ช่วยจำปุ่มลัด (กด space แล้วรอ) ─────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      win = { border = "rounded" },
      spec = {
        { "<leader>f", group = "󰈞 หาไฟล์ / ค้นหา" },
        { "<leader>c", group = "󰅱 โค้ด / LSP" },
        { "<leader>g", group = " git" },
        { "<leader>b", group = "󰓩 buffer" },
        { "<leader>s", group = "󰤼 แบ่งจอ" },
        { "<leader>x", group = "󰅚 รายการ error" },
        { "<leader>t", group = " terminal" },
        { "<leader>u", group = "󰔃 สลับเปิด/ปิด" },
      },
    },
    keys = {
      { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "ปุ่มลัดของ buffer นี้" },
    },
  },

  -- ── เลื่อนจอแบบลื่น ๆ ───────────────────────────────
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = { easing = "quadratic", duration_multiplier = 0.6 },
  },

  -- ── โชว์สีจริงของโค้ดสี (สำคัญมากเวลาทำ CSS/Tailwind) ─
  {
    "brenoprata10/nvim-highlight-colors",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      render = "virtual",
      virtual_symbol = "󰝤",
      virtual_symbol_position = "inline",
      enable_tailwind = true,
      enable_named_colors = true,
    },
  },

  -- ── เน้นคำที่เคอร์เซอร์อยู่ ให้เห็นทุกจุดที่ใช้ ────────
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("illuminate").configure({
        providers = { "lsp", "treesitter", "regex" },
        delay = 150,
        filetypes_denylist = { "alpha", "neo-tree", "lazy", "mason", "Trouble" },
      })
    end,
  },
}
