return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha     = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- ── โลโก้ ────────────────────────────────────────
    dashboard.section.header.val = {
      [[                                                  ]],
      [[██╗    ██╗ █████╗ ██╗  ██╗ █████╗ ███████╗███████╗]],
      [[██║    ██║██╔══██╗██║ ██╔╝██╔══██╗╚══███╔╝██╔════╝]],
      [[██║ █╗ ██║███████║█████╔╝ ███████║  ███╔╝ █████╗  ]],
      [[██║███╗██║██╔══██║██╔═██╗ ██╔══██║ ███╔╝  ██╔══╝  ]],
      [[╚███╔███╔╝██║  ██║██║  ██╗██║  ██║███████╗███████╗]],
      [[ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝]],
      [[      ♥   n e o v i m   ·   f u l l s t a c k   ♥ ]],
    }

    -- ไล่เฉดม่วง → ชมพู → ฟ้า ทีละบรรทัด
    local grad = { "#585b70", "#cba6f7", "#c9a2f5", "#d8a3ef", "#e8a4e8", "#f5c2e7", "#b4befe", "#89b4fa" }
    local hl = {}
    for i, color in ipairs(grad) do
      local group = "AlphaGrad" .. i
      vim.api.nvim_set_hl(0, group, { fg = color, bold = true })
      hl[i] = { { group, 0, 200 } }
    end
    dashboard.section.header.opts.hl = hl

    -- ── ปุ่มเมนู ──────────────────────────────────────
    vim.api.nvim_set_hl(0, "AlphaBtn",      { fg = "#89b4fa" })
    vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = "#f5c2e7", italic = true, bold = true })
    vim.api.nvim_set_hl(0, "AlphaFooter",   { fg = "#6c7086", italic = true })

    local function btn(sc, icon, txt, cmd)
      local b = dashboard.button(sc, icon .. "  " .. txt, cmd)
      b.opts.hl          = "AlphaBtn"
      b.opts.hl_shortcut = "AlphaShortcut"
      b.opts.width       = 44
      return b
    end

    dashboard.section.buttons.val = {
      btn("f", "󰈞", "หาไฟล์               ", "<cmd>Telescope find_files<cr>"),
      btn("r", "󰄉", "ไฟล์ล่าสุด            ", "<cmd>Telescope oldfiles<cr>"),
      btn("g", "󰈬", "ค้นหาข้อความทั้งโปรเจกต์ ", "<cmd>Telescope live_grep<cr>"),
      btn("e", "󰙅", "เปิดตัวจัดการไฟล์       ", "<cmd>Neotree toggle<cr>"),
      btn("n", "󰈔", "ไฟล์ใหม่              ", "<cmd>ene | startinsert<cr>"),
      btn("c", "󰒓", "แก้คอนฟิก nvim        ", "<cmd>e ~/.config/nvim/init.lua<cr>"),
      btn("m", "󰏖", "จัดการ LSP (Mason)    ", "<cmd>Mason<cr>"),
      btn("L", "󰒲", "จัดการปลั๊กอิน (Lazy)  ", "<cmd>Lazy<cr>"),
      btn("q", "󰗼", "ออก                  ", "<cmd>qa<cr>"),
    }
    dashboard.section.buttons.opts.spacing = 0

    -- ── คำคมสุ่ม ──────────────────────────────────────
    local quotes = {
      "頑張って！ — สู้ ๆ นะ วันนี้ก็เขียนโค้ดให้สนุก",
      "( ｡•̀ ᴗ - ) ♥  senpai noticed your commit",
      "โค้ดที่ดีที่สุด คือโค้ดที่ไม่ต้องเขียน",
      "デバッグ中… — บั๊กไม่ได้หายไป มันแค่ย้ายที่",
      "หนึ่ง commit ต่อวัน หมอไม่ต้องมาเยี่ยม",
      "ยังไม่ต้องรีแฟกเตอร์ ทำให้มันทำงานได้ก่อน",
      "ไม่มีปัญหาไหนที่แก้ไม่ได้ มีแต่กาแฟที่ยังไม่พอ",
      "コードは詩だ — โค้ดก็คือบทกวีอย่างหนึ่ง",
      "อ่านง่ายกว่าฉลาด · ชัดเจนกว่าสั้น",
      "( ๑˃̵ᴗ˂̵ )♪  another day, another feature",
    }
    math.randomseed(os.time())
    local quote = quotes[math.random(#quotes)]

    dashboard.section.footer.val = { "", quote }
    dashboard.section.footer.opts.hl = "AlphaFooter"

    dashboard.opts.layout = {
      { type = "padding", val = 2 },
      dashboard.section.header,
      { type = "padding", val = 2 },
      dashboard.section.buttons,
      dashboard.section.footer,
    }
    dashboard.opts.opts.noautocmd = true

    alpha.setup(dashboard.opts)

    -- ต่อท้าย footer ด้วยจำนวนปลั๊กอิน + เวลาเปิด
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      once = true,
      callback = function()
        local s  = require("lazy").stats()
        local ms = math.floor(s.startuptime * 100 + 0.5) / 100
        dashboard.section.footer.val = {
          "",
          ("󰒲  %d ปลั๊กอิน  ·  󰥔  เปิดใน %sms  ·  nvim %s"):format(
            s.loaded, ms, tostring(vim.version())
          ),
          "",
          quote,
        }
        pcall(vim.cmd.AlphaRedraw)
      end,
    })
  end,
}
