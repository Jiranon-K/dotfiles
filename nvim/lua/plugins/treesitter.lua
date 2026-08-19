return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdate", "TSInstall", "TSInstallInfo" },
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        -- เว็บ / fullstack
        "javascript", "typescript", "tsx", "html", "css", "scss",
        "json", "jsonc", "yaml", "toml", "graphql", "prisma", "sql",
        "vue", "svelte", "astro",
        -- หลังบ้าน / สคริปต์
        "python", "bash", "lua", "luadoc", "go", "rust", "php",
        -- อื่น ๆ
        "markdown", "markdown_inline", "dockerfile", "gitignore",
        "gitcommit", "git_rebase", "diff", "regex", "vim", "vimdoc", "query",
      },
      auto_install = true,
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection    = "<C-space>",
          node_incremental  = "<C-space>",
          node_decremental  = "<BS>",
          scope_incremental = false,
        },
      },
    },
  },

  -- ปิดแท็ก HTML/JSX ให้อัตโนมัติ (ขาดไม่ได้สำหรับ React)
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
}
