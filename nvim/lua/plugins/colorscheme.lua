return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,   -- ทะลุไปเห็นพื้นเบลอม่วงของ kitty
      show_end_of_buffer = false,
      term_colors = true,
      no_italic = false,
      styles = {
        comments     = { "italic" },
        conditionals = { "italic" },
        keywords     = { "italic" },
        functions    = { "bold" },
        types        = { "italic" },
      },
      integrations = {
        alpha             = true,
        blink_cmp         = true,
        flash             = true,
        gitsigns          = true,
        mason             = true,
        neotree           = true,
        noice             = true,
        notify            = true,
        treesitter        = true,
        which_key         = true,
        lsp_trouble       = true,
        illuminate        = { enabled = true },
        telescope         = { enabled = true },
        indent_blankline  = { enabled = true, scope_color = "mauve", colored_indent_levels = false },
        native_lsp = {
          enabled = true,
          virtual_text = { errors = { "italic" }, hints = { "italic" }, warnings = { "italic" } },
          underlines  = { errors = { "underline" }, hints = { "underline" }, warnings = { "underline" } },
          inlay_hints = { background = false },
        },
      },
      custom_highlights = function(c)
        return {
          -- ขอบมนสีม่วงพาสเทลให้เข้ากับ kitty
          FloatBorder      = { fg = c.mauve, bg = "NONE" },
          NormalFloat      = { bg = "NONE" },
          FloatTitle       = { fg = c.pink, style = { "bold" } },
          WinSeparator     = { fg = c.surface1 },
          CursorLineNr     = { fg = c.pink, style = { "bold" } },
          LineNr           = { fg = c.surface1 },
          Visual           = { bg = c.surface1, style = { "bold" } },
          Search           = { fg = c.base, bg = c.pink },
          IncSearch        = { fg = c.base, bg = c.peach },
          MatchParen       = { fg = c.peach, style = { "bold" } },
          -- popup เติมเต็มให้อ่านง่ายกว่าโปร่งล้วน
          Pmenu            = { bg = c.mantle },
          PmenuSel         = { bg = c.surface1, style = { "bold" } },
          TelescopeNormal  = { bg = "NONE" },
          TelescopeBorder  = { fg = c.mauve, bg = "NONE" },
          NeoTreeNormal    = { bg = "NONE" },
          NeoTreeNormalNC  = { bg = "NONE" },
          NeoTreeWinSeparator = { fg = c.surface0, bg = "NONE" },
        }
      end,
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
