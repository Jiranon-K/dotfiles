return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      {
        "mason-org/mason.nvim",
        cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonLog" },
        opts = {
          ui = {
            border = "rounded",
            backdrop = 100,
            icons = { package_installed = " ", package_pending = " ", package_uninstalled = " " },
          },
        },
      },
      "mason-org/mason-lspconfig.nvim",
      "b0o/schemastore.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      -- ── ปุ่มลัดตอน LSP ติดกับไฟล์ ────────────────────
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("wakaze_lsp_attach", { clear = true }),
        callback = function(ev)
          local buf = ev.buf
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc, silent = true })
          end

          map("n", "gd", "<cmd>Telescope lsp_definitions<cr>",      "󰈮 ไปที่นิยาม")
          map("n", "gr", "<cmd>Telescope lsp_references<cr>",       "󰈇 หาที่ถูกเรียกใช้")
          map("n", "gI", "<cmd>Telescope lsp_implementations<cr>",  "󰡱 ไปที่ implementation")
          map("n", "gy", "<cmd>Telescope lsp_type_definitions<cr>", "󰜁 ไปที่ type")
          map("n", "gD", vim.lsp.buf.declaration,                   "󰈮 ไปที่ declaration")
          map("n", "K",  function() vim.lsp.buf.hover({ border = "rounded" }) end, "󰋖 ดูคำอธิบาย")
          map({ "n", "i" }, "<C-k>", function() vim.lsp.buf.signature_help({ border = "rounded" }) end, "󰊕 ดูพารามิเตอร์")
          map("n", "<leader>cr", vim.lsp.buf.rename,      "󰑕 เปลี่ยนชื่อทั้งโปรเจกต์")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "󰌵 แก้ให้อัตโนมัติ (code action)")

          -- inlay hints: โชว์ type แทรกในบรรทัด
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = buf })
            map("n", "<leader>uh", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
            end, "󰊤 เปิด/ปิด inlay hint")
          end
        end,
      })

      -- ── ค่าเริ่มต้นของทุก server ─────────────────────
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- ── ตั้งค่าเฉพาะบาง server ───────────────────────
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
            diagnostics = { globals = { "vim" } },
            hint = { enable = true },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.config("ts_ls", {
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "literals",
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = false,
              includeInlayFunctionLikeReturnTypeHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "literals",
              includeInlayFunctionParameterTypeHints = true,
            },
          },
        },
      })

      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" },
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      })

      vim.lsp.config("emmet_language_server", {
        filetypes = {
          "html", "css", "scss", "less", "sass",
          "javascriptreact", "typescriptreact", "vue", "svelte", "astro", "php",
        },
      })

      vim.lsp.config("tailwindcss", {
        filetypes = {
          "html", "css", "scss", "javascript", "javascriptreact",
          "typescript", "typescriptreact", "vue", "svelte", "astro", "php",
        },
      })

      -- ── ให้ mason ลง server แล้วเปิดใช้อัตโนมัติ ──────
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",                  -- Lua (คอนฟิก nvim เอง)
          "ts_ls",                   -- JavaScript / TypeScript
          "eslint",                  -- ตรวจโค้ด JS/TS
          "html", "cssls",           -- HTML / CSS
          "tailwindcss",             -- Tailwind
          "emmet_language_server",   -- พิมพ์ย่อ HTML
          "jsonls", "yamlls",        -- JSON / YAML
          "bashls",                  -- shell script
          "dockerls",                -- Dockerfile
          "pyright",                 -- Python
        },
        automatic_enable = true,
      })
    end,
  },
}
