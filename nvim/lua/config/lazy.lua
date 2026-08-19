-- ติดตั้ง lazy.nvim อัตโนมัติถ้ายังไม่มี
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "โคลน lazy.nvim ไม่สำเร็จ:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nกดปุ่มใดก็ได้เพื่อออก..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  defaults = { lazy = true, version = false },
  install = { colorscheme = { "catppuccin", "habamax" } },
  checker = { enabled = true, notify = false },   -- เช็คอัปเดตเงียบ ๆ
  change_detection = { notify = false },
  ui = {
    border = "rounded",
    backdrop = 100,          -- ไม่หรี่จอ ให้เห็นพื้นหลังโปร่ง
    icons = { lazy = "󰒲 " },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin", "netrwPlugin", "rplugin",
      },
    },
  },
})

vim.keymap.set("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "󰒲 จัดการปลั๊กอิน" })
