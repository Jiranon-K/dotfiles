local function augroup(name)
  return vim.api.nvim_create_augroup("wakaze_" .. name, { clear = true })
end

-- ไฮไลต์แวบ ๆ ตอน yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function() vim.hl.on_yank({ higroup = "Visual", timeout = 180 }) end,
})

-- กลับไปบรรทัดเดิมตอนเปิดไฟล์ซ้ำ
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(ev)
    if vim.b[ev.buf].last_loc then return end
    vim.b[ev.buf].last_loc = true
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ตัดช่องว่างท้ายบรรทัดตอนบันทึก
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("trim_ws"),
  callback = function()
    local save = vim.fn.winsaveview()
    pcall(function() vim.cmd([[keeppatterns %s/\s\+$//e]]) end)
    vim.fn.winrestview(save)
  end,
})

-- ปิดหน้าต่างพวกนี้ด้วย q เฉย ๆ
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = { "help", "man", "qf", "lspinfo", "checkhealth", "notify", "startuptime" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})

-- ปรับขนาดจอที่แบ่งไว้อัตโนมัติเมื่อย่อ/ขยายหน้าต่าง
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize"),
  command = "tabdo wincmd =",
})

-- สร้างโฟลเดอร์ให้อัตโนมัติถ้ายังไม่มีตอนเซฟ
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("mkdir"),
  callback = function(ev)
    if ev.match:match("^%w%w+://") then return end
    vim.fn.mkdir(vim.fn.fnamemodify(vim.uv.fs_realpath(ev.match) or ev.match, ":p:h"), "p")
  end,
})

-- เปิด wrap + spell ในไฟล์ข้อความ
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_text"),
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})
