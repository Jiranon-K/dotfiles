-- leader ต้องตั้งก่อนโหลด lazy เสมอ
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

-- ── หน้าตา ───────────────────────────────────────────
opt.number         = true
opt.relativenumber = true
opt.cursorline     = true
opt.signcolumn     = "yes"
opt.termguicolors  = true
opt.background     = "dark"
opt.showmode       = false   -- lualine โชว์ให้แล้ว
opt.cmdheight      = 0       -- noice เอาไปทำ popup
opt.laststatus     = 3       -- statusline เส้นเดียวทั้งจอ
opt.pumheight      = 12
opt.pumblend       = 8
opt.winborder      = "rounded"
opt.fillchars      = { eob = " ", fold = " ", foldopen = "▾", foldclose = "▸" }
opt.list           = true
opt.listchars      = { tab = "▏ ", trail = "·", nbsp = "␣" }

-- ── แก้ไข ────────────────────────────────────────────
opt.expandtab   = true
opt.shiftwidth  = 2
opt.tabstop     = 2
opt.softtabstop = 2
opt.smartindent = true
opt.wrap        = false
opt.linebreak   = true
opt.scrolloff   = 8
opt.sidescrolloff = 8
opt.virtualedit = "block"

-- ── ค้นหา ────────────────────────────────────────────
opt.ignorecase = true
opt.smartcase  = true
opt.hlsearch   = true
opt.incsearch  = true
opt.inccommand = "split"   -- พรีวิว :%s สด ๆ

-- ── ไฟล์ / undo ──────────────────────────────────────
opt.undofile   = true
opt.swapfile   = false
opt.backup     = false
opt.autoread   = true
opt.updatetime = 200
opt.timeoutlen = 400

-- ── หน้าต่าง ─────────────────────────────────────────
opt.splitright = true
opt.splitbelow = true
opt.splitkeep  = "screen"

-- ── อื่น ๆ ───────────────────────────────────────────
opt.mouse       = "a"
opt.clipboard   = "unnamedplus"
opt.confirm     = true
opt.completeopt = "menu,menuone,noselect"
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help" }

-- ── fold ด้วย treesitter (เปิดไว้หมดตอนเปิดไฟล์) ──────
opt.foldmethod = "expr"
opt.foldexpr   = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext   = ""
opt.foldlevel  = 99

-- ── diagnostic ───────────────────────────────────────
vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 4, source = "if_many" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN]  = "󰀪 ",
      [vim.diagnostic.severity.HINT]  = "󰌶 ",
      [vim.diagnostic.severity.INFO]  = "󰋽 ",
    },
  },
  underline       = true,
  update_in_insert = false,
  severity_sort   = true,
  float = { border = "rounded", source = true, header = "", prefix = "" },
})

-- ── ปิด provider ที่ไม่ได้ใช้ (เปิดเร็วขึ้น + ไม่มี warning) ──
-- ถ้าวันหลังลงปลั๊กอินที่ต้องใช้ ให้ลบบรรทัดที่เกี่ยวข้องออก
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider    = 0
vim.g.loaded_ruby_provider    = 0
vim.g.loaded_node_provider    = 0
