<div align="center">

# ✿ wakaze/dotfiles

**kitty** + **neovim** · Catppuccin Mocha · transparent, blurred, pastel

`new machine → one command → exactly the same setup`

</div>

---

## Install

```bash
git clone https://github.com/Jiranon-K/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

The script handles everything:

| Step | What it does |
|---|---|
| 1 | Detect the package manager (`dnf` / `apt` / `pacman`) |
| 2 | Install dependencies — neovim, kitty, ripgrep, fd, node, gcc, make |
| 3 | Install **Cascadia Code NF** if missing, and check for Thai fonts |
| 4 | Symlink configs into `~/.config/` (**existing configs are moved to `.backup-<timestamp>`, never deleted**) |
| 5 | Install neovim plugins at the versions pinned in `lazy-lock.json` |
| 6 | Compile treesitter parsers |
| 7 | Install LSP servers and formatters via mason |

Safe to re-run — already-correct symlinks are skipped.

---

## What's inside

### 🐱 kitty

Cascadia Code NF + Noto Sans Thai (Thai renders properly, no tofu boxes), background opacity `0.92`
with blur `48`, beam cursor with a motion trail, no window decorations, slanted tabs that only
appear when there's more than one.

Notable binding — `Shift+Enter` inserts a newline without submitting (for the Claude Code CLI).

### 📝 neovim

Built directly on `lazy.nvim`, not a distro — readable, hackable, starts in **~20 ms**.

<table>
<tr><td><b>Theme</b></td><td>Catppuccin Mocha, transparent so kitty's blur shows through</td></tr>
<tr><td><b>Dashboard</b></td><td>alpha-nvim, gradient logo grey→mauve→pink→blue with random quotes</td></tr>
<tr><td><b>Fuzzy find</b></td><td>telescope + fzf-native</td></tr>
<tr><td><b>File tree</b></td><td>neo-tree</td></tr>
<tr><td><b>Completion</b></td><td>blink.cmp (prebuilt binaries — no Rust toolchain needed)</td></tr>
<tr><td><b>LSP</b></td><td>mason + the new <code>vim.lsp.config</code> API from nvim 0.11+</td></tr>
<tr><td><b>Formatting</b></td><td>conform.nvim — prettierd / stylua / black+isort / shfmt, on save</td></tr>
<tr><td><b>Git</b></td><td>gitsigns</td></tr>
<tr><td><b>UI</b></td><td>lualine · bufferline · noice · which-key · indent-blankline</td></tr>
<tr><td><b>Editing</b></td><td>flash · surround · autopairs · todo-comments · trouble · toggleterm</td></tr>
</table>

**Languages covered** — TypeScript / JavaScript / React / Vue / Svelte / Astro,
HTML / CSS / Tailwind / Emmet, JSON / YAML, Python, Bash, Docker, Lua, Go, Rust, PHP, SQL, Prisma, GraphQL

---

## Keybindings

Three to start with:

```
Space Space   →  find files
Ctrl + n      →  toggle file tree
Space (hold)  →  which-key shows you the rest
```

<details>
<summary><b>More — leader is Space</b></summary>

| Group | Keys | Action |
|---|---|---|
| **Files** | `<leader>ff` `<leader>fg` `<leader>fb` `<leader>fo` | find file · live grep · buffers · recent |
| **Code** | `gd` `gr` `K` `<leader>ca` `<leader>cr` `<leader>cf` | definition · references · hover · code action · rename · format |
| **Git** | `]h` `[h` `<leader>gp` `<leader>gb` `<leader>gd` | next/prev hunk · preview · blame · diff |
| **Diagnostics** | `<leader>xx` `<leader>e` `]d` `[d` | trouble · float · next/prev |
| **Buffers** | `Shift+l` `Shift+h` `<leader>bd` | cycle · close |
| **Windows** | `<leader>sv` `<leader>sh` `Ctrl+hjkl` | split vertical/horizontal · navigate |
| **Terminal** | `Ctrl+\` `<leader>tf` | floating |
| **Jump** | `s` `S` | flash · flash treesitter |

</details>

📋 **[Full searchable cheatsheet →](https://claude.ai/code/artifact/e2c864b0-7041-4de1-a1e8-aebb2df5117f)**

---

## Editing the config

After install, `~/.config/nvim` and `~/.config/kitty` are **symlinks into this repo** —
edit either path and you're editing the same file. Commit and push when you're happy:

```bash
cd ~/dotfiles
git add -A && git commit -m "tweak: ..." && git push
```

Pull on another machine:

```bash
cd ~/dotfiles && git pull
```

**Adding a plugin** — drop a new file in `nvim/lua/plugins/` containing `return { "author/plugin" }`.
lazy.nvim imports every file in that directory automatically.

---

## Structure

```
dotfiles/
├── install.sh              ← run this
├── kitty/
│   ├── kitty.conf          fonts · window · keybindings
│   └── theme.conf          Catppuccin Mocha
└── nvim/
    ├── init.lua
    ├── lazy-lock.json      pinned plugin versions — identical on every machine
    └── lua/
        ├── config/         options · keymaps · autocmds · lazy
        └── plugins/        one file per concern
```

---

## Requirements

- **neovim ≥ 0.10** — the config uses `vim.uv` and `vim.lsp.config` (`install.sh` checks this)
- **git · curl · unzip · gcc · make** — for building treesitter parsers
- **A Nerd Font** — `install.sh` fetches Cascadia Code NF if you don't have one
- **node** — for the web LSP servers (ts / html / css / tailwind / eslint)

---

<div align="center">
<sub>Tested on Fedora 44 · GNOME Wayland · neovim 0.12</sub><br>
<sub>♡ 頑張って！</sub>
</div>
