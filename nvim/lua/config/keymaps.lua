local map = vim.keymap.set

-- ── พื้นฐาน ──────────────────────────────────────────
map("i", "jk", "<Esc>", { desc = "ออกจากโหมดพิมพ์" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "ล้างไฮไลต์ผลค้นหา" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "󰆓 บันทึกไฟล์" })
map("n", "<leader>W", "<cmd>wa<cr>", { desc = "󰆓 บันทึกทุกไฟล์" })
map("n", "<leader>q", "<cmd>confirm q<cr>", { desc = "󰗼 ปิดหน้าต่าง" })
map("n", "<leader>Q", "<cmd>confirm qa<cr>", { desc = "󰗼 ออกจาก nvim" })

-- ── สลับหน้าต่าง ─────────────────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "ไปหน้าต่างซ้าย" })
map("n", "<C-j>", "<C-w>j", { desc = "ไปหน้าต่างล่าง" })
map("n", "<C-k>", "<C-w>k", { desc = "ไปหน้าต่างบน" })
map("n", "<C-l>", "<C-w>l", { desc = "ไปหน้าต่างขวา" })
map("n", "<leader>sv", "<C-w>v", { desc = "แบ่งจอซ้าย-ขวา" })
map("n", "<leader>sh", "<C-w>s", { desc = "แบ่งจอบน-ล่าง" })
map("n", "<leader>sx", "<cmd>close<cr>", { desc = "ปิดจอที่แบ่ง" })
map("n", "<C-Up>",    "<cmd>resize +2<cr>",          { desc = "ขยายจอสูง" })
map("n", "<C-Down>",  "<cmd>resize -2<cr>",          { desc = "ลดจอสูง" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>", { desc = "ลดจอกว้าง" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "ขยายจอกว้าง" })

-- ── buffer (ไฟล์ที่เปิดอยู่) ──────────────────────────
map("n", "<S-l>", "<cmd>bnext<cr>",     { desc = "ไฟล์ถัดไป" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "ไฟล์ก่อนหน้า" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "󰅖 ปิดไฟล์นี้" })
map("n", "<leader>bo", "<cmd>%bd|e#|bd#<cr>", { desc = "󰅖 ปิดไฟล์อื่นทั้งหมด" })

-- ── ย้ายบรรทัด / เยื้อง ───────────────────────────────
map("n", "<A-j>", "<cmd>m .+1<cr>==",       { desc = "ย้ายบรรทัดลง" })
map("n", "<A-k>", "<cmd>m .-2<cr>==",       { desc = "ย้ายบรรทัดขึ้น" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv",       { desc = "ย้ายบล็อกลง" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv",       { desc = "ย้ายบล็อกขึ้น" })
map("v", "<", "<gv", { desc = "เยื้องซ้าย (ไม่หลุด select)" })
map("v", ">", ">gv", { desc = "เยื้องขวา (ไม่หลุด select)" })

-- ── เลื่อนจอแล้วเคอร์เซอร์อยู่กลาง ────────────────────
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- ── วาง/ลบ โดยไม่ทับ clipboard ───────────────────────
map("x", "<leader>p", [["_dP]], { desc = "วางทับโดยไม่กิน clipboard" })
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "ลบทิ้งโดยไม่กิน clipboard" })

-- ── โหมด terminal ────────────────────────────────────
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "ออกจากโหมด terminal" })

-- ── diagnostic ───────────────────────────────────────
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "󰋽 ดู error บรรทัดนี้" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "error ก่อนหน้า" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1 })  end, { desc = "error ถัดไป" })
