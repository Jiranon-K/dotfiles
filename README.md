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
| 2 | Install dependencies — neovim, kitty, ripgrep, fd, jq, node, gcc, make |
| 3 | Install **Cascadia Code NF** if missing, and check for Thai fonts |
| 4 | Symlink configs into `~/.config/` (**existing configs are moved to `.backup-<timestamp>`, never deleted**) |
| 5 | Install neovim plugins at the versions pinned in `lazy-lock.json` |
| 6 | Compile treesitter parsers |
| 7 | Install LSP servers and formatters via mason |
| 8 | Wire the statusline into `~/.claude/settings.json` if Claude Code is installed |

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

### ✿ claude code statusline

Two lines for the Claude Code CLI, in the same Catppuccin Mocha palette as kitty and neovim.

```
✿ ~/dotfiles   main●3 │ opus 5 · high │ tok 94.4k/200k 47%  ▰▰▰▰▰▰▰▰▰▱▱▱▱▱▱▱▱▱▱▱ │ $0.42
usage  5h ▰▰▰▰▰▱▱▱▱▱▱▱▱▱▱▱▱▱ 33%  1h │ 7d ▰▰▰▱▱▱▱▱▱▱▱▱▱▱▱▱▱▱ 17%  3d
```

**Line 1 — this session**

| Segment | Meaning |
| --- | --- |
| `✿ path` | Working directory, shortened to the last two components |
| ` branch●3` | Git branch — green when clean, yellow with `●n` when *n* files are modified. Hidden outside a repo |
| `opus 5 · high` | Active model and reasoning effort (effort only shows on models that take it) |
| `tok 94.4k/200k 47%` | Context window, straight from the CLI's own `context_window` field. Adapts to the 200k / 1M window |
| `$0.42` | Session cost, shown once it passes one cent |

**Line 2 — account limits**

`5h` and `7d` are the rolling usage limits, each with a bar, a percentage, and the time until it
resets. The whole line disappears when the CLI reports no limits — API-key accounts, or before the
first request of a session.

Bars run teal → yellow at 50% → peach at 70% → red at 90%, the same scale everywhere, so one glance
across both lines tells you which gauge is the one to worry about.

The usage-limit segments need a Claude Code build that passes `rate_limits` to the statusline
(verified on 2.1.235 and 2.1.237). Older builds simply omit them.

**Tuning** — the top of `claude/statusline.sh` has the knobs:

| Variable | Default | |
| --- | --- | --- |
| `BAR_ON` / `BAR_OFF` | `▰` `▱` | Bar characters. Both exist in Cascadia Code NF — swapping in `￭` / `･` needs a CJK fallback font, and the widths stop lining up |
| `CTX_W` / `USE_W` | `20` / `18` | Bar lengths. Drop them on a narrow terminal |
| `SHOW_5H` | `1` | Set to `0` for the weekly limit only |

`install.sh` wires it up automatically (needs `jq`). To set it up by hand, add this to
`~/.claude/settings.json`:

```json
"statusLine": { "type": "command", "command": "~/dotfiles/claude/statusline.sh", "padding": 0 }
```

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
├── claude/
│   └── statusline.sh       Claude Code CLI statusline
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

## Related

System-level stuff — Fedora packages, COPR/RPM Fusion repos, Flatpaks, GNOME extensions
and the whole `dconf` tree — lives in a separate (private) repo: **`Jiranon-K/fedora-setup`**.
Its `restore.sh` clones this repo and runs `install.sh` as its final step.

---

## Requirements

- **neovim ≥ 0.10** — the config uses `vim.uv` and `vim.lsp.config` (`install.sh` checks this)
- **git · curl · unzip · gcc · make** — for building treesitter parsers
- **A Nerd Font** — `install.sh` fetches Cascadia Code NF if you don't have one
- **node** — for the web LSP servers (ts / html / css / tailwind / eslint)
- **jq** — only for the Claude Code statusline; everything else works without it

---

<div align="center">
<sub>Tested on Fedora 44 · GNOME Wayland · neovim 0.12</sub><br>
<sub>♡ 頑張って！</sub>
</div>
